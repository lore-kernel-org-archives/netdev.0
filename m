From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack
 crash, etc)
Date: Tue, 28 Jun 2016 21:30:50 +0800
Message-ID: <20160628133050.GA18468@gondor.apana.org.au>
References: <20160628124241.GA17940@gondor.apana.org.au>
 <20160628132301.11479.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth@vger.kernel.org, linux-crypto@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39609 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbcF1NbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:31:07 -0400
Content-Disposition: inline
In-Reply-To: <20160628132301.11479.qmail@ns.sciencehorizons.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 09:23:01AM -0400, George Spelvin wrote:
> 
> Wow, I should see how you do that.  I couldn't get it below 3
> blocks of temporary, and the dst SG list only gives you
> one and a half.

I don't mean that I'm using no temporary buffers at all, just
that the actual crypto only operates on the SG lists.  I'm still
doing the xoring and stitching in temp buffers.  I just counted
and I'm using three blocks like you.

> Is net/sunrpc/auth_gss/gss_krb5_mech.c doing something odd?

Yes gss_krb5_crypto.c is the one.

> I have a request of you: like Andy, I find the crypto layer an
> impenetrable thicket of wrapper structures.  I'm not suggesting there
> aren't reasons for it, but it's extremely hard to infer those reasons by
> looking at the code.  If I were to draft a (hilariously wrong) overview
> document, would you be willing to edit it into correctness?

We have actually gained quite a bit of documentation recently.
Have you looked at Documentation/DocBook/crypto-API.tmpl?

More is always welcome of course.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
