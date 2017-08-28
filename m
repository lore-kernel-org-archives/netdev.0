From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: add debugfs interface
Date: Mon, 28 Aug 2017 22:19:08 +0200
Message-ID: <20170828201908.GC1870@lunn.ch>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
 <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828191748.19492-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2017 at 03:17:39PM -0400, Vivien Didelot wrote:
> This commit adds a DEBUG_FS dependent DSA core file creating a generic
> debug filesystem interface for the DSA switch devices.
> 
> The interface can be mounted with:
> 
>     # mount -t debugfs none /sys/kernel/debug
> 
> The dsa directory contains one directory per switch chip:
> 
>     # cd /sys/kernel/debug/dsa/
>     # ls
>     switch0  switch1 switch2
> 
> Each chip directory contains one directory per port:
> 
>     # ls -l switch0/
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port0
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port1
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port2
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port5
>     drwxr-xr-x 2 root root 0 Jan  1 00:00 port6
> 
> Future patches will add entry files to these directories.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
