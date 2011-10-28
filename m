From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH 2/2 v3] net/smsc911x: Add regulator support
Date: Sat, 29 Oct 2011 01:33:16 +0200
Message-ID: <CAJaTeTqerTxTnxB9jkeYGUkCRoaeOuzQPaQ0jyE7yjw7jO6rFQ@mail.gmail.com>
References: <1319719691-15799-1-git-send-email-linus.walleij@stericsson.com> <20111028203353.GE23421@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@stericsson.com>,
	netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert Marklund <robert.marklund@stericsson.com>,
	Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>, linux-omap@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20111028203353.GE23421@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 28, 2011 at 22:33, Sascha Hauer wrote:
> On Thu, Oct 27, 2011 at 02:48:11PM +0200, Linus Walleij wrote:
>> +/*
>> + * Request or free resources, currently just regulators.
>> + *
>> + * The SMSC911x has two power pins: vddvario and vdd33a, in designs=
 where
>> + * these are not always-on we need to request regulators to be turn=
ed on
>> + * before we can try to access the device registers.
>> + */
>> +static int smsc911x_request_free_resources(struct platform_device *=
pdev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 bool request)
>
> I had to look twice at this function name. First I thought "request t=
he
> free resources?", which other resources would you request if not the
> free ones? I think it would be nicer to have two functions instead.
> Just my 2 cents.

i'll add my 2 cents and we'll almost have a nickle.  maybe i'm dense,
but i had to look (more than) twice at both funcs before i could get
my head around what was happening.  no, it's not complicated, but it
is unusual in the kernel world.  either that or i haven't read enough
kernel code to consider this a common paradigm.  hopefully it's the
former ;).
-mike
--
To unsubscribe from this list: send the line "unsubscribe linux-omap" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
