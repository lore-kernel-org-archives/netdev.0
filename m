From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] Name magic constants in sock_wake_async()
Date: Mon, 26 Nov 2007 20:06:15 +0800
Message-ID: <20071126120615.GC26599@gondor.apana.org.au>
References: <4746D8EF.8010806@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1745 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754135AbXKZMGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 07:06:19 -0500
Content-Disposition: inline
In-Reply-To: <4746D8EF.8010806@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 04:43:11PM +0300, Pavel Emelyanov wrote:
> The sock_wake_async() performs a bit different actions 
> depending on "how" argument. Unfortunately this argument 
> ony has numerical magic values.
> 
> I propose to give names to their constants to help people 
> reading this function callers understand what's going on 
> without looking into this function all the time.
> 
> I suppose this is 2.6.25 material, but if it's not (or the
> naming seems poor/bad/awful), I can rework it against the 
> current net-2.6 tree.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I like this but I admit I'm no good with names either :)

Patch applied to net-2.6.25.  Thanks Pavel!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
