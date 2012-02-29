From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 00/12] Part 2: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Wed, 29 Feb 2012 08:02:49 +0100
Message-ID: <201202290802.52234.danny.kukawka@bisect.de>
References: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de> <CAHXqBFK=u+MchBn=D31h6nhp-R9GTNbaC18QJA937zjXc60UQw@mail.gmail.com> <CAMuHMdVZ8eVdRLtsq23XCLtA4wU7cTc-mLebAQ4QzO=gkuNMWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Guo-Fu Tseng" <cooldavid@cooldavid.org>,
	Petko Manolov <petkan@users.sourceforge.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"John W. Linville" <linville@tuxdriver.com>, linux390@de.ibm.com,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-mips@linux-mips.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdVZ8eVdRLtsq23XCLtA4wU7cTc-mLebAQ4QzO=gkuNMWQ@mail.gmail.com>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Samstag, 25. Februar 2012, Geert Uytterhoeven wrote:
> 2012/2/24 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> > 2012/2/24 Danny Kukawka <danny.kukawka@bisect.de>:
> >> Second Part of series patches to unifiy the return value of
> >> .ndo_set_mac_address if the given address isn't valid.
> >>
> >> These changes check if a given (MAC) address is valid in
> >> .ndo_set_mac_address, if invalid return -EADDRNOTAVAIL
> >> as eth_mac_addr() already does if is_valid_ether_addr() fails.
> >
> > Why not just fix dev_set_mac_address() and make do_setlink() use th=
at?
>
> BTW, it's also called from dev_set_mac_address().
>
> > Checks are specific to address family, not device model I assume.
>
> Indeed, why can't this be done in one single place, instead of sprink=
ling
> these checks over all drivers, missing all out-of-tree (note: I don't=
 care)
> and all soon-to-be-submitted drivers?

Since the .ndo_set_mac_address functions are used by some drivers inter=
nally=20
too, you may get some new checks on other places. But I'll take a look =
at it.

Danny

--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
