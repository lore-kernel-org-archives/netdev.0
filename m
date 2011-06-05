From: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Sun, 5 Jun 2011 10:34:45 +0200
Message-ID: <20110605083445.GT16318@ibawizard.net>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
Reply-To: Petr =?iso-8859-2?Q?=A9tetiar?= <ynezz@true.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org, hsweeten@visionengravers.com
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Mika Westerberg <mika.westerberg@iki.fi> [2011-06-02 21:59:34]:

> As the driver is now passing platform device to the DMA mapping functions,
> we should give it valid DMA masks.

Hi Mika,

do you have the series available somewhere for pull? I would like to test the
changes for you on my ts7250/ts7300, but I'm quite lazy and would like to just
cherry-pick the changes if possible :-)

I also wonder, why this patch[1] from Herbert Valerio Riedel has never made it
upstream, this email[2] is the last trace of the patch I could find. Looks
like Herbert did few fixes to the driver and thanks to Matthieu, I'm using
this forward ported patch[3] since today, without any problems.

Do you personaly use the ethernet on the ep93xx/ts72xx heavily?

1. http://ynezz.ibawizard.net/ts72xx/linux-kernel/2.6.24.y/ep93xx-eth-phylib-framework.patch
2. http://www.mail-archive.com/netdev@vger.kernel.org/msg62550.html
3. https://github.com/ynezz/linux-2.6/commit/1dcf7aeb7ca4d7e441be2467926b606b46060a44

-- ynezz
