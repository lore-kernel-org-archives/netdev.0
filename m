From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] tun: Limit amount of queued packets per device
Date: Sat, 14 Feb 2009 20:46:46 -0800 (PST)
Message-ID: <20090214.204646.200136639.davem@davemloft.net>
References: <20090212111313.GD13859@gondor.apana.org.au>
	<1234467301.25178.305.camel@bling>
	<20090215031506.GA7749@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46723
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbZBOEqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 23:46:52 -0500
In-Reply-To: <20090215031506.GA7749@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 15 Feb 2009 11:15:06 +0800

> On Thu, Feb 12, 2009 at 12:35:01PM -0700, Alex Williamson wrote:
> > 
> > Current net-next-2.6 (v2.6.29-rc2-1715-g367681f).  I just reverified it
> > with kvm-userspace (kvm-83-389-ga1efe3d).  The problem goes away if I
> > patch -R commit 33dccbb.
> 
> Sorry, my fault for not testing the merged result.
> 
> tun: Fix merge error
> 
> When forward-porting the tun accounting patch I managed to break
> the send path compltely by dropping the tun_get call.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
