From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Fri, 07 Jun 2013 14:48:16 +0200
Message-ID: <6204768.NxiQ5EdAsp@wuerfel>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com> <2468036.im0srnzmHT@wuerfel> <4881796E12491D4BB15146FE0209CE643F5C8E99@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5C8E99@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 07 June 2013 12:37:24 Alexey Brodkin wrote:
> On 06/07/2013 04:13 PM, Arnd Bergmann wrote:
> >>> I wonder if it would be better to name the directory "synopsys" or
> >>> "designware" rather than "arc" now. Is there a chance that the same
> >>> controller is used on non-arc CPUs?
> >>
> >> The thing is - "arc_emac" is a custom ARC's (that was implemented before
> >> acquisition of ARC by Synopsys) IP (it's not an IC - just a part of CPU)
> >> Ethernet controller that only exists in some legacy FPGA boards we
> >> (ex-ARC and our customers) still use a lot in development process.
> >>
> >> Synopsys itself doesn't actively sell this device so there's no point in
> >> putting ARC EMAC into Synopsys folder.
> >>
> >> And indeed we don't expect this device to be used with non-ARC CPU's.
> 
> I'm wondering if my clarification above makes sense and I may leave this 
> driver in "ethernet/arc" or you still prefer it to be under 
> "ethernet/synopsys"?

Yes, I think if we don't expect any future Synopsys/Designware branded
devices to use this, using ethernet/arc is fine.

The main reason to still use a different name is so we will be able
to group it with other drivers for designware ethernet controllers.

The only one I'm currently aware of is drivers/net/ethernet/stmicro/stmmac/.
If we wanted to ahve a designware directory, we should probably move that
as well.

I'll leave it up to you (or Dave, if he has a strong opinion).

	Arnd
