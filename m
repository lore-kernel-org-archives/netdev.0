From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch -mainline] af_key: more info leaks in pfkey messages
Date: Thu, 25 Jul 2013 11:24:38 +0300
Message-ID: <20130725082438.GZ5585@mwanda>
References: <20130724103956.GA30345@elgon.mountain>
 <20130725073205.GQ3109@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mathias Krause <minipli@googlemail.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33653 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755098Ab3GYIZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 04:25:00 -0400
Content-Disposition: inline
In-Reply-To: <20130725073205.GQ3109@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 09:32:06AM +0200, Steffen Klassert wrote:
> Userspace seems not to care, but the correct setting would be
> 
> pol->sadb_x_policy_priority = xp->priority;
> 
> So maybe we should send the right priority to userspace, just for
> the case that anyone is interested in it.
> 

Yep.  Of course.  Thanks.  I will redo and resend.

regards,
dan carpenter
