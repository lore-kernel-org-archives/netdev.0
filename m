From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Fri, 22 Jun 2007 15:32:34 +0200
Message-ID: <20070622133234.GA3756@ff.dom.local>
References: <4bacf17f0706161435g1bb7c08bpd427901f64d57fa@mail.gmail.com> <20070618110849.GA2450@ff.dom.local> <20070618081000.14da5186@localhost.localdomain> <20070619055007.GB1649@ff.dom.local> <4bacf17f0706220156j63c4ec4ah75ac13ba653a3e67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0706220156j63c4ec4ah75ac13ba653a3e67@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 22, 2007 at 10:56:44AM +0200, Marcin =A6lusarz wrote:
=2E..
> When I disable on-board network card in BIOS (controlled by skge)
> ne2k-pci card is still locking up. So I think it's strictly ne2k-pci
> card bug. I made some tests and I know how to reproduce it fast (on m=
y
> machine) - just make some heavy network traffic...
=2E..

I'm no good at hardware, but I guess this log could be not enough.
So, if nobody will find something more sensible, maybe you can try
some of these suggestions:

- you've written it was OK with 2.6.20; it would be interesting
to check if there were any changes in config (beside new options)
or even retry 2.6.20 with "current" config after make oldconfig;
- during such problems it's better to try to turn off as much
unnecessary options/drivers as possible to find if it's really
about network driver; e.g.: no SMP, tv cards, acpi - only
basic, without options etc.;
- if possible try it with newer kernel e.g. 2.6.22-rc5;
- if possible try it with another, fresh distro (e.g. some live
CD/DVD/USB bootable);
- there was a lockdep warning from tvtime/bttv;
- try to get some more debugging (help: modinfo ne2k-pci).

Regards,
Jarek P.

PS: for anybody interested - here is the beginning of this story:
http://marc.info/?l=3Dlinux-kernel&m=3D118202978609968&w=3D2
