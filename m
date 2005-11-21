From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH -mm2] net: Fix compiler-error on dgrs.c when !CONFIG_PCI
Date: Tue, 22 Nov 2005 09:12:52 +1100
Message-ID: <E1EeJu8-0006vr-00@gondolin.me.apana.org.au>
References: <43824066.4080109@student.ltu.se>
Cc: herbert@gondor.apana.org.au, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, ashutosh.naik@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751147AbVKUWNH@vger.kernel.org>
To: ricknu-0@student.ltu.se (Richard Knutsson)
In-Reply-To: <43824066.4080109@student.ltu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Knutsson <ricknu-0@student.ltu.se> wrote:
>
> We need it even if pci_register_driver() and pci_register_driver() is 
> empty shells. And instead of removing #endif CONFIG_PCI for 

I don't think so.  Please see my previous patch where pci_register_driver
is not called at all if CONFIG_PCI is not defined.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
