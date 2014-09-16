From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Tue, 16 Sep 2014 22:26:59 +0200
Message-ID: <1410899219.31130.81.camel@x220>
References: <1403091974.1984.102.camel@x220> <1409911856.7832.9.camel@x220>
	 <CAHNKnsRipRHicKOUW4dCutD1-sUG6qPnP2QuOveH_t1MFX9XgQ@mail.gmail.com>
	 <1409916824.7832.20.camel@x220>
	 <CAHNKnsQ1gt=DRBTd9Q9yos1idqmXMepEPvhm8a7unP-whzNAgg@mail.gmail.com>
	 <20140909182734.GJ29412@tuxdriver.com>
	 <CAHNKnsQ8G3ZFHshq7wOqex1J6DbVD5uHVAyvs+aDC2Znk5zWww@mail.gmail.com>
	 <541037D2.7060007@gmail.com>
	 <CAHNKnsTtqz10c=vV-f10awLanYZzom3kJ1cO5xgTGs-t3O9NYg@mail.gmail.com>
	 <20140911192146.GC22872@tuxdriver.com>
	 <20140915184546.GB3891@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergey Ryazanov <ryazanov.s.a@gmail.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Oleksij Rempel <linux@rempel-privat.de>,
	Richard Weinberger <richard@nod.at>,
	Jonathan Bither <jonbither@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	ath5k-devel@venema.h4ckr.net, open@hauke-m.de,
	"list@hauke-m.de:NETWORKING DRIVERS" <list@hauke-m.de>,
	"antonynpavlov@gmail.com" <antonynpavlov@gmail.com>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"list@hauke-m.de:NETWORKING DRIVERS" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140915184546.GB3891@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-15 at 14:45 -0400, John W. Linville wrote:
> FYI -- Sergey posted a series to linux-mips on 14 September 2014 that
> touches the symbol in question.  For whatever reason, it is posted
> there as RFC.

Thanks for passing that on.

> Does this satisfy the interested parties??

In case I qualify as an interested party: resolving this by, in short,
making AHB support actually buildable is of course the preferable
solution. 

Whether or not we should drop my patch while waiting for that series to
land in linux-next is not my call. But if it hasn't landed by, say,
about the time v3.18-rc3 is released I might raise this issue again.

I must say that I'm a bit puzzled why people have resisted this rather
small cleanup for years. How did having unbuildable AHB support in
mainline benefit anyone? Couldn't the revert of this cleanup also be
handled out of tree? Note that the revert is only "6 files changed, 3
insertions(+), 294 deletions(-)", while the series is "39 files changed,
3911 insertions(+), 10 deletions(-)".


Paul Bolle
