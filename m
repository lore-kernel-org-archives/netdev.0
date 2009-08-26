From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Date: Wed, 26 Aug 2009 11:51:18 +0200
Message-ID: <20090826095118.GA26280@cmpxchg.org>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <_yaHeGjHEzG.A.FIH.7sGlKB@chimera> <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com> <20090826082741.GA25955@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
To: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090826082741.GA25955-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 26, 2009 at 10:27:41AM +0200, Johannes Weiner wrote:

> 64 pages, presumably 256k, for fw->boot_size while current ipw
> firmware images have ~188k.  I don't know jack squat about this
> driver, but given the field name and the struct:
> 
> 	struct ipw_fw {
> 		__le32 ver;
> 		__le32 boot_size;
> 		__le32 ucode_size;
> 		__le32 fw_size;
> 		u8 data[0];
> 	};
> 
> fw->boot_size alone being that big sounds a bit fishy to me.

Scrap that, I just noticed the second call to ipw_load_firmware() a
few lines later... :)

	Hannes 'when logic and proportion have fallen sloppy dead...'
