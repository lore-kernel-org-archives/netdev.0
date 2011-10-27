From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Fri, 28 Oct 2011 00:43:35 +0200
Message-ID: <CAJaTeTpPxmFKa4D-NOXvuoL52esaouT-tkCupZm86nR1ZFVfxA@mail.gmail.com>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com>
 <CAJaTeTrzFwxsn22U-NHQ8iCiaUM+mj8PyicavR-DN0HgE08ZEQ@mail.gmail.com>
 <20111027154638.GA16946@sirena.org.uk> <CAJaTeTpzFOdgqGH3vDWY8Mdx7zra8R9nUQYHgsEBfy_yGkEWOw@mail.gmail.com>
 <20111027214241.GA11534@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@stericsson.com>,
	netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20111027214241.GA11534@opensource.wolfsonmicro.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2011 at 23:42, Mark Brown wrote:
> On Thu, Oct 27, 2011 at 10:59:14PM +0200, Mike Frysinger wrote:
>> i saw that !CONFIG_REGULATOR works great. =A0my concern is that thes=
e
>> boards don't define any regulators for smsc resources, so if
>> CONFIG_REGULATOR is enabled to test out unrelated daughter cards, i
>> don't want the network driver suddenly failing. =A0Linus' comments
>> suggest that this is what would happen unless each board file has it=
s
>> smsc platform resources extended. =A0maybe i misunderstood what he w=
as saying ?
>
> That's the case that's handled by CONFIG_REGULATOR_DUMMY - if the loo=
kup
> fails the core will provide a virtual regulator to the consumer. =A0I=
f
> you're running a setup like that you probably want to enable dummy
> regulators anyway.

ok, if people configuring need only select that Kconfig symbol to make
it work, i'm fine with things.  thanks for the explanation.
-mike
