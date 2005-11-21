From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Tue, 22 Nov 2005 10:36:09 +1100
Message-ID: <20051121233609.GB27327@gondor.apana.org.au>
References: <E1EeJu8-0006vr-00@gondolin.me.apana.org.au> <4382563E.50502@student.ltu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932482AbVKUXgX@vger.kernel.org>
To: Richard Knutsson <ricknu-0@student.ltu.se>
Content-Disposition: inline
In-Reply-To: <4382563E.50502@student.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 22, 2005 at 12:20:30AM +0100, Richard Knutsson wrote:
> 
> Am thinking of removing the #ifdef CONFIG_PCI's in other files, to 
> "clean up" the code, but that would introduce this problem again, don't 
> you think it is more readable to make an empty struct when !CONFIG_PCI, 
> then making new pci_*-functions specific to the driver?

I think my version is more readable.  However, it's really up to Jeff
to decide.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
