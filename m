From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs
 interface
Date: Mon, 28 Aug 2017 21:38:37 -0700 (PDT)
Message-ID: <20170828.213837.1354872205076475221.davem@davemloft.net>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        privat@egil-hjelmeland.no, john@phrozen.org,
        Woojung.Huh@microchip.com, sean.wang@mediatek.com,
        nikita.yoush@cogentembedded.com, cphealy@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 28 Aug 2017 15:17:38 -0400

> This patch series adds a generic debugfs interface for the DSA
> framework, so that all switch devices benefit from it, e.g. Marvell,
> Broadcom, Microchip or any other DSA driver.

I've been thinking this over and I agree with the feedback given that
debugfs really isn't appropriate for this.

Please create a DSA device class, and hang these values under
appropriate sysfs device nodes that can be easily found via
/sys/class/dsa/ just as easily as they would be /sys/kernel/debug/dsa/

You really intend these values to be consistent across DSA devices,
and you don't intend to go willy-nilly changig these exported values
arbitrarily over time.  That's what debugfs is for, throw-away
stuff.

So please make these proper device sysfs attributes rather than
debugfs.

Thank you.
