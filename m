From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 21:45:21 -0800 (PST)
Message-ID: <20090114.214521.132298096.davem@davemloft.net>
References: <20090114.210242.163189105.davem@davemloft.net>
	<496ECACB.5090300@cn.fujitsu.com>
	<20090115053702.GA30403@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yanghy@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753327AbZAOFpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:45:19 -0500
In-Reply-To: <20090115053702.GA30403@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 16:37:02 +1100

> On Thu, Jan 15, 2009 at 01:34:03PM +0800, Yang Hongyang wrote:
> > 
> > Dave,there are some of the code elsewhere return EFAULT when
> > optval=NULL,I will post a patch to fix them:)
> 
> I disagree.  The concept of a user-space NULL pointer is different
> to that of a kernel-space NULL pointer, so the kernel should not
> be treating a user-space NULL pointer differently than any other
> pointer.

I agree with Herbert, but of course we have to adhere to cases
where APIs actually define a user NULL pointer to have a specific
meaning.
