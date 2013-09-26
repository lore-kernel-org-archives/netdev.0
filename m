From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [PATCH] ARM: shmobile: Lager: add Micrel KSZ8041 PHY fixup
Date: Wed, 25 Sep 2013 23:50:45 -0700
Message-ID: <CANqRtoTiHQ3EVDZ8POCkyN2ga95rF=u5ERfYsdZbX+toqAWmaQ@mail.gmail.com>
References: <201309140429.23474.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Simon Horman [Horms]" <horms@verge.net.au>,
	SH-Linux <linux-sh@vger.kernel.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201309140429.23474.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 13, 2013 at 5:29 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Currently on the Lager board NFS timeouts/delays are seen when booting.  That
> turned out to happen because the SoC's ETH_LINK signal turns on and off after
> each packet.  It is connected to Micrel KSZ8041 PHY's LED0 signal. Ether LEDs
> on the Lager board are named LINK and ACTIVE which corresponds to non-default
> 01 setting of the PHY control register 1 bits 14-15. The 'sh_eth' driver resets
> the PHY when opening the network device, so we have to set the mentioned bits
> back to 01 from the default 00 value which causes bouncing of ETH_LINK.  That
> can be achieved using the PHY platform fixup mechanism if we also modify the
> driver to use it..
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Hi Sergei,

Thanks for your efforts on this. Nice to see that Ethernet for Lager
board support is improving.

Can you please share with us with link speeds you tested? I suspect
that this patch is only needed for some case, like for instance 100
MBit Full Duplex. Fixing the PHY settings makes sense even though only
a single mode needs it, but knowing which link speeds that are known
to work would help a lot.

Cheers,

/ magnus
