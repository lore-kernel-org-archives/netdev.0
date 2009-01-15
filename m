From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 21:02:42 -0800 (PST)
Message-ID: <20090114.210242.163189105.davem@davemloft.net>
References: <496D61FE.7080500@cn.fujitsu.com>
	<20090114044856.GA14726@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757843AbZAOFCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:02:41 -0500
In-Reply-To: <20090114044856.GA14726@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Jan 2009 15:48:56 +1100

> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
> >
> > If optval==NULL, what we should return?EINVAL or EFAULT?
> > If it is EINVAL,then we should check it .otherwise it's the job of 
> > copy_from_user
> 
> I think EFAULT is fine.  We return that elsewhere as well.

Actually, we return EINVAL just a few lines above this code
block for some other socket option cases when optval==NULL.

So for consistency I'm applying Yang's original patch to
net-next-2.6

Thanks.
