From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 003/007] WAN Drivers: Update farsync driver and
 introduce fsflex driver
Date: Wed, 18 Sep 2013 16:33:52 +0100
Message-ID: <1379518432.1522.18.camel@bwh-desktop.uk.level5networks.com>
References: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA2@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"Dermot Smith" <dermot.smith@farsite.com>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA2@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 11:12 +0100, Kevin Curtis wrote:
> Farsite Communications FarSync driver update
> 
> Patch 3 of 7
> 
> Introduce a new include file required by the fsflex driver.
> 
> Signed-off-by: Kevin Curtis <kevin.curtis@farsite.com>
> 
> ---
> 
> diff -uprN -X linux-3.10.1/Documentation/dontdiff linux-3.10.1/drivers/net/wan/fscmn.h linux-3.10.1_new/drivers/net/wan/fscmn.h
> --- linux-3.10.1/drivers/net/wan/fscmn.h	1970-01-01 01:00:00.000000000 +0100
> +++ linux-3.10.1_new/drivers/net/wan/fscmn.h	2013-09-16 16:30:06.779104868 +0100
[...]
> +#ifdef UINT32
> +#define u32 UINT32
> +#define u16 UINT16
> +#define u8  UCHAR
> +#endif
> +
> +#ifdef USSTYPES_H
> +#define u32 U32
> +#define u16 U16
> +#define u8  U8
> +#endif
[...]

This sort of cruft doesn't belong in an in-tree driver.  unifdef may be
useful for removing it when copying in out-of-tree 'portable' code.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
