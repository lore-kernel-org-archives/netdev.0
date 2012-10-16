From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Tue, 16 Oct 2012 14:26:47 -0700
Message-ID: <20121016212647.GM15569@atomide.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com>
 <20121016174835.GV15569@atomide.com>
 <507DCA8D.7060309@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
	Afzal Mohammed <afzal@ti.com>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	"hvaibhav@ti.com" <hvaibhav@ti.com>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Jon Hunter <jon-hunter@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <507DCA8D.7060309@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jon Hunter <jon-hunter@ti.com> [121016 14:00]:
> Hi Tony,
> 
> On 10/16/2012 12:48 PM, Tony Lindgren wrote:
> > * Richard Cochran <richardcochran@gmail.com> [121015 12:18]:
> >> From: hvaibhav@ti.com <hvaibhav@ti.com>
> >>
> >> With recent changes in omap gpmc driver code, in case of DT
> >> boot mode, where bootloader does not configure gpmc cs space
> >> will result into kernel BUG() inside gpmc_mem_init() function,
> >> as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
> >> gpmc_config7[0].baseaddress is set to '0' on reset.
> >>
> >> This use-case is applicable for any board/EVM which doesn't have
> >> any peripheral connected to gpmc cs0, for example BeagleXM and
> >> BeagleBone, so DT boot mode fails.
> >>
> >> This patch adds of_have_populated_dt() check before creating
> >> device, so that for DT boot mode, gpmc probe will not be called
> >> which is expected behavior, as gpmc is not supported yet from DT.
> > 
> > I'm applying this one into omap-for-v3.7-rc1/fixes-part2.
> > 
> > Next time, please also cc linux-omap@vger.kernel.org for series
> > like this. I'm sure the people reading the omap list are interested
> > in these.
> 
> This patch appears to be masking an underlying issue. How about 
> something like the following ...

OK that looks good to me. I'll drop the earlier fix and use
yours instead.

Regards,

Tony
