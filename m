From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 01/11] Removing dead RT2800PCI_SOC
Date: Wed, 14 Jul 2010 09:15:27 -0400
Message-ID: <20100714131527.GB2352@tuxdriver.com>
References: <cover.1279110894.git.siccegge@cs.fau.de>
 <29013fb6eab9e95e95d61df894797d2455dfa10c.1279110894.git.siccegge@cs.fau.de>
 <AANLkTinO32CIe0HBTXjP_bcAz0nMEw6wvcZwcob1fX3r@mail.gmail.com>
 <AANLkTikCeDys9e1EnE9GdiJtDRcbqW3gzvsmjzvB_yDs@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Egger <siccegge-n+aIp8eCc/CzQB+pC5nmwQ@public.gmane.org>,
	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	Helmut Schaa <helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	vamos-dev-DSeRVwK2yFR7NQr57o4jwX20dTPRyWU8FLXUG6abMr4@public.gmane.org,
	Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ivo Van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikCeDys9e1EnE9GdiJtDRcbqW3gzvsmjzvB_yDs-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 14, 2010 at 02:52:14PM +0200, Ivo Van Doorn wrote:
> On Wed, Jul 14, 2010 at 2:46 PM, Luis Correia <luis.f.correia-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Wed, Jul 14, 2010 at 13:39, Christoph Egger <siccegge-n+aIp8eCc/CzQB+pC5nmwQ@public.gmane.org> wrote:
> >> While RT2800PCI_SOC exists in Kconfig, it depends on either
> >> RALINK_RT288X or RALINK_RT305X which are both not available in Kconfig
> >> so all Code depending on that can't ever be selected and, if there's
> >> no plan to add these options, should be cleaned up
> >>
> >> Signed-off-by: Christoph Egger <siccegge-n+aIp8eCc/CzQB+pC5nmwQ@public.gmane.org>
> >
> > NAK,
> >
> > this is not dead code, it is needed for the Ralink System-on-Chip
> > Platform devices.
> >
> > While I can't fix Kconfig errors and the current KConfig file may be
> > wrong, this code cannot and will not be deleted.
> 
> When the config option was introduced, the config options RALINK_RT288X and
> RALINK_RT305X were supposed to be merged as well soon after by somebody (Felix?)
> 
> But since testing is done on SoC boards by Helmut and Felix, I assume the code
> isn't dead but actually in use.

Perhaps Helmut and Felix can send us the missing code?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
