From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 00/18] net: dsa: mv88e6xxx: 802.1s and 88E6390 VTU
Date: Mon, 01 May 2017 11:51:05 -0400
Message-ID: <871ss8bmom.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

> Vivien Didelot (18):
>   net: dsa: mv88e6xxx: add max VID to info
>   net: dsa: mv88e6xxx: split VTU entry data member
>   net: dsa: mv88e6xxx: move VTU Operation accessors
>   net: dsa: mv88e6xxx: move VTU flush
>   net: dsa: mv88e6xxx: move VTU FID accessors
>   net: dsa: mv88e6xxx: move VTU SID accessors
>   net: dsa: mv88e6xxx: move VTU VID accessors
>   net: dsa: mv88e6xxx: move generic VTU GetNext
>   net: dsa: mv88e6xxx: move VTU Data accessors
>   net: dsa: mv88e6xxx: move STU GetNext operation
>   net: dsa: mv88e6xxx: get STU entry on VTU GetNext
>   net: dsa: mv88e6xxx: load STU entry with VTU entry
>   net: dsa: mv88e6xxx: add VTU GetNext operation
>   net: dsa: mv88e6xxx: add VTU Load/Purge operation
>   net: dsa: mv88e6xxx: make VTU helpers static
>   net: dsa: mv88e6xxx: simplify VTU entry getter
>   net: dsa: mv88e6xxx: support the VTU Page bit
>   net: dsa: mv88e6xxx: add VTU support for 88E6390
>
>  drivers/net/dsa/mv88e6xxx/Makefile      |   1 +
>  drivers/net/dsa/mv88e6xxx/chip.c        | 568 +++++++++-----------------------
>  drivers/net/dsa/mv88e6xxx/global1.h     |  14 +
>  drivers/net/dsa/mv88e6xxx/global1_vtu.c | 505 ++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/mv88e6xxx.h   |  31 +-
>  5 files changed, 684 insertions(+), 435 deletions(-)
>  create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c

I don't see the patchset in net-next. Can you pick it?

Thanks,

        Vivien
