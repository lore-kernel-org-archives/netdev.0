From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 00/10] net: dsa: add generic debugfs interface
Date: Mon, 28 Aug 2017 21:53:32 +0200
Message-ID: <20170828195332.GB1950@nanopsycho.orion>
References: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Chris Healy <cphealy@gmail.com>, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828191748.19492-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Aug 28, 2017 at 09:17:38PM CEST, vivien.didelot@savoirfairelinux.com wrote:
>This patch series adds a generic debugfs interface for the DSA
>framework, so that all switch devices benefit from it, e.g. Marvell,
>Broadcom, Microchip or any other DSA driver.
>
>This is really convenient for debugging, especially CPU ports and DSA
>links which are not exposed to userspace as net device. This interface
>is currently the only way to easily inspect the hardware for such ports.
>
>With the patch series, any switch device user is able to query the
>hardware for the supported tagging protocol, the ports stats and
>registers, as well as their FDB, MDB and VLAN entries.

I see this overlaps a lot with DPIPE. Why won't you use that to expose
your hw state?
