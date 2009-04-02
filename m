From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2 V3] kaweth: Fix locking to be SMP-safe
Date: Thu, 2 Apr 2009 23:29:36 +0800
Message-ID: <20090402152936.GA1670@gondor.apana.org.au>
References: <20090402100223.GA30905@gondor.apana.org.au> <49D4D37A.50504@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, oliver@neukum.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763784AbZDBPaO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D4D37A.50504@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 02, 2009 at 10:02:18AM -0500, Larry Finger wrote:
>
> The .ndo_poll_controller callback is left at NULL in this driver. I believe the
> patch to be OK.

Good point!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
