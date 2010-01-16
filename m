From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Sat, 16 Jan 2010 01:20:04 -0800 (PST)
Message-ID: <20100116.012004.166836523.davem@davemloft.net>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com
To: Tristram.Ha@Micrel.Com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752404Ab0APJT5@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Date: Fri, 15 Jan 2010 18:57:59 -0800

> The KSZ8842 has a switch with lots of hardware configurations.  The =
> driver uses the proc system to allow users to configure the switch.  If =
> this is not desired the whole thing can be removed by not calling the =
> init_proc() function.

I think there needs to be a serious discussion about how
this driver uses bridge layer internals by doing things like:

+/* Needed for STP support. */
+#ifdef CONFIG_KSZ8842_STP
+#include <../net/bridge/br_private.h>
+#endif

and uses procfs to configure the ports.

Stephen please look this over and make suggestions for better
ways to support and configure these kinds of devices.

Thanks.
