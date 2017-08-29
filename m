From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Tue, 29 Aug 2017 08:29:31 +0200
Message-ID: <20170829062931.GB1977@nanopsycho.orion>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828.213837.1354872205076475221.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        f.fainelli@gmail.com, andrew@lunn.ch, privat@egil-hjelmeland.no,
        john@phrozen.org, Woojung.Huh@microchip.com,
        sean.wang@mediatek.com, nikita.yoush@cogentembedded.com,
        cphealy@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828.213837.1354872205076475221.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Aug 29, 2017 at 06:38:37AM CEST, davem@davemloft.net wrote:
>From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>Date: Mon, 28 Aug 2017 15:17:38 -0400
>
>> This patch series adds a generic debugfs interface for the DSA
>> framework, so that all switch devices benefit from it, e.g. Marvell,
>> Broadcom, Microchip or any other DSA driver.
>
>I've been thinking this over and I agree with the feedback given that
>debugfs really isn't appropriate for this.
>
>Please create a DSA device class, and hang these values under
>appropriate sysfs device nodes that can be easily found via
>/sys/class/dsa/ just as easily as they would be /sys/kernel/debug/dsa/
>
>You really intend these values to be consistent across DSA devices,
>and you don't intend to go willy-nilly changig these exported values
>arbitrarily over time.  That's what debugfs is for, throw-away
>stuff.
>
>So please make these proper device sysfs attributes rather than
>debugfs.

As I wrote, I believe that there is a big overlap with devlink and its
dpipe subset. I think that primary we should focus on extending whatever
is needed for dsa there. The iface should be generic for all drivers,
not only dsa. dsa-specific sysfs attributes should be last-resort solution,
I believe we can avoid them.
