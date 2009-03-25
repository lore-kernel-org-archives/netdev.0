From: Subrata Modak <tosubrata@gmail.com>
Subject: Re: [PATCH] Re: Next March 25: net/netfilter/xt_LED build failure.
Date: Wed, 25 Mar 2009 20:01:42 +0530
Message-ID: <20090325143142.6171.24387.sendpatchset@subratamodak.linux.ibm.com>
Cc: Sachin Sant <sachinp@in.ibm.com>,
	Subrata Modak <tosubrata@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-next@vger.kernel.org, Adam Nielsen <a.nielsen@shikadi.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

>Does this patch fix it?

Sorry, yes it does for make. But i was executing:

make net/netfilter/xt_LED.o

>
><diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
>index 2562d05..2c967e4 100644
>--- a/net/netfilter/Kconfig
>+++ b/net/netfilter/Kconfig
>@@ -374,7 +374,7 @@ config NETFILTER_XT_TARGET_HL
>
> config NETFILTER_XT_TARGET_LED
>       tristate '"LED" target support'
>-       depends on LEDS_CLASS
>+       depends on LEDS_CLASS && LED_TRIGGERS
>       depends on NETFILTER_ADVANCED
>       help
>         This option adds a `LED' target, which allows you to blink LEDs in

Thanks.

Regards--
Subrata
