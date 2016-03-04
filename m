From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Fri, 04 Mar 2016 22:00:17 +0100
Message-ID: <18726591.PV3KNmkGar@wuerfel>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de> <1659125.tHp8H942OG@wuerfel> <56D9D189.8080206@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: isdn@linux-pingi.de, devel@driverdev.osuosl.org,
	Jonathan Corbet <corbet@lwn.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <56D9D189.8080206@linux-pingi.de>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 04 March 2016 19:18:49 isdn@linux-pingi.de wrote:
> Am 04.03.2016 um 16:24 schrieb Arnd Bergmann:
> > On Thursday 03 March 2016 09:30:38 isdn@linux-pingi.de wrote:
> >> Hi Arnd,
> >> I fully agree and ack.
> >> Thanks for the work.
> >>
> > 
> > I actually did more patches that I ended up not submitting:
> > 
> > * move hisax to staging
> > * remove i4l support from gigaset
> > * move i4l core to staging
> > 
> > while I initially thought that i4l as a whole is not just unmaintained
> > but also more or less unused, patch 19cebbcb04c8 ("isdn: Partially
> > revert debug format string usage clean up") came in that indicated that
> > there are still users that even send patches for hisax, and that
> > made me doubt whether we could consider it obsolete enough.
> > 
> > Any thoughts on this? If you like, I can send those too.
> 
> I4L is still in use on some sides and here is no 100% replacement (net
> via RAW IP mode, terminal via X.75).

I see.

> This week I got some question from a big retail chain  in Germany about
> migration. I never know that they are  using this stuff (for initial
> setup of remote shops).

Just for more background, do you know how old the kernel is that they
(or other i4l users you know of) are currently using?

> So I would not drop i4l yet, maybe we should propose this for 2018.
> I4L is not so usefull for NT mode, which is very popular nowadays for
> gateways into the new full IP world. Some design ins with mISDN here,
> mostly in the embedded area.

Ok, with a planned 2018 removal date I think we can consider moving
it all to staging now, that would give at least everyone who still uses
modern kernels a warning ahead of time so they can either plan the
migration away from i4l (or away from ISDN in other cases), as well as
a chance for us to hear about any remaining active users and whether
they need a later removal date.

In the TODO file for the active ISDN drivers, I have listed 2017
after the longterm kernel as the date for the projected removal.
If we decide to move the rest of I4L to staging with a date of
2018 (after the longterm release), that gives users at least until
2020 before they stop seeing upstream bug fixes for a kernel with
an included i4l, and many are probably stuck with running unsupported
older kernels anyway.

For reference, the currently largest provider of ISDN phone lines
is Deutsche Telekom, and they plan to disconnect their last user
in 2018, while Vodafone Germany said they will continue their service
until 2022, but my interpretation of their website fine print is that
this is only true for expensive S2M connections that few people use.

	Arnd
