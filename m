From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Thu, 15 Jan 2009 13:34:03 +0800
Message-ID: <496ECACB.5090300@cn.fujitsu.com>
References: <496D61FE.7080500@cn.fujitsu.com>	<20090114044856.GA14726@gondor.apana.org.au> <20090114.210242.163189105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54735 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbZAOFd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 00:33:56 -0500
In-Reply-To: <20090114.210242.163189105.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 14 Jan 2009 15:48:56 +1100
> 
>> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>> If optval==NULL, what we should return?EINVAL or EFAULT?
>>> If it is EINVAL,then we should check it .otherwise it's the job of 
>>> copy_from_user
>> I think EFAULT is fine.  We return that elsewhere as well.
> 
> Actually, we return EINVAL just a few lines above this code
> block for some other socket option cases when optval==NULL.
> 
> So for consistency I'm applying Yang's original patch to
> net-next-2.6

Dave,there are some of the code elsewhere return EFAULT when
optval=NULL,I will post a patch to fix them:)

> 
> Thanks.
> 
> 


-- 
Regards
Yang Hongyang
