From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Improve sequence number generation.
Date: Sun, 21 Aug 2011 12:02:45 +0800
Message-ID: <20110821040244.GA21405__3999.57129634476$1313899444$gmane$org@gondor.apana.org.au>
References: <20110821012844.GA15222@1wt.eu> <20110821030415.18106.qmail@science.horizon.com> <20110821032753.GA8992@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Ted Ts'o <tytso@mit.edu>, George Spelvin <linux@horizon.com>,
	w@1wt.eu, dan@doxpara.com, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, linux-kernel@vger.kernel.org,
	mpm@selenic.com, net
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37278 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699Ab1HUEDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 00:03:35 -0400
Content-Disposition: inline
In-Reply-To: <20110821032753.GA8992@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2011 at 11:27:53PM -0400, Ted Ts'o wrote:
> Here's a random thought --- it won't help on anything other than
> modern x86's, but who's to say we have to use the same algorithm on
> all platforms?  Does the AES-NI facility provide enough of a speedup
> that it's worth using it instead of MD5, at least on modern x86
> systems which have this support?

It is fast but it also touches SSE state.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
