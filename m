From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 00/13] net: dsa: lan9303: unicast offload, fdb,mdb,STP
Date: Mon, 24 Jul 2017 09:54:45 -0700
Message-ID: <db9b265a-ed4a-c6f7-8959-21c9314a6ec0@gmail.com>
References: <525d9bb74bfa42c1b7a54930e14cf5ea@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Egil Hjelmeland <egil.hjelmeland@zenitel.com>, corbet@lwn.net,
        andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525d9bb74bfa42c1b7a54930e14cf5ea@nooslMX1.zenitelcss.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 07/24/2017 07:47 AM, Egil Hjelmeland wrote:
> This series extends the LAN9303 3 port switch DSA driver. Highlights:
>  - Make the MDIO interface work
>  - Bridging: Unicast offload
>  - Bridging: Added fdb/mdb handling
>  - Bridging: STP support
>  - Documentation
> 
> The last three patches are workarounds due to current kernel limitations.
> 
> This is my first patches submitted to the kernel, so I am looking
> forward to comments.

First thing would be to get your patch submissions square, because the
patches do not appear to have been sent as a reply to this cover letter,
and worse yet, they are all appearing with their commit date, which is
highly confusing since that makes them go back in time for some of them.

I will reply to the other patches as well.

> 
> 
> Egil Hjelmeland (13):
>   net: dsa: lan9303: Fixed MDIO interface
>   net: dsa: lan9303: Do not disable/enable switch fabric port 0 at
>     startup
>   net: dsa: lan9303: Refactor lan9303_enable_packet_processing()
>   net: dsa: lan9303: Added adjust_link() method
>   net: dsa: added dsa_net_device_to_dsa_port()
>   net: dsa: lan9303: added sysfs node swe_bcst_throt
>   net: dsa: lan9303: Added basic offloading of unicast traffic
>   net: dsa: lan9303: Added ALR/fdb/mdb handling
>   net: dsa: lan9303: Added Documentation/networking/dsa/lan9303.txt
>   net: dsa: lan9303: Only allocate 3 ports
>   net: dsa: lan9303: Added "alr_dump" sysfs port attribute
>   net: dsa: lan9303: Added "stp_enable" sysfs attribute
>   net: dsa: lan9303: lan9303_port_mdb_del remove port 0
> 
>  Documentation/networking/dsa/lan9303.txt |  74 +++
>  drivers/net/dsa/lan9303-core.c           | 811 ++++++++++++++++++++++++++++---
>  drivers/net/dsa/lan9303.h                |  23 +
>  drivers/net/dsa/lan9303_i2c.c            |   2 +
>  drivers/net/dsa/lan9303_mdio.c           |  34 ++
>  include/net/dsa.h                        |   1 +
>  net/dsa/slave.c                          |  10 +
>  7 files changed, 885 insertions(+), 70 deletions(-)
>  create mode 100644 Documentation/networking/dsa/lan9303.txt
> 


-- 
Florian
