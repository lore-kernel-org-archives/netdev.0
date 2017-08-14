From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 06/11] net: dsa: debugfs: add port registers
Date: Tue, 15 Aug 2017 00:46:32 +0200
Message-ID: <20170814224632.GC16885@lunn.ch>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-7-vivien.didelot@savoirfairelinux.com>
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
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170814222242.10643-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 06:22:37PM -0400, Vivien Didelot wrote:
> Add a debug filesystem "regs" entry to query a port's hardware registers
> through the .get_regs_len and .get_regs_len switch operations.
> 
> This is very convenient because it allows one to dump the registers of
> DSA links, which are not exposed to userspace.
> 
> Here are the registers of a zii-rev-b CPU and DSA ports:
> 
>     # pr -mt switch0/port{5,6}/regs
>      0: 4e07			     0: 4d04
>      1: 403e			     1: 003d
>      2: 0000			     2: 0000
>      3: 3521			     3: 3521
>      4: 0533			     4: 373f
>      5: 8000			     5: 0000
>      6: 005f			     6: 003f
>      7: 002a			     7: 002a
>      8: 2080			     8: 2080
>      9: 0001			     9: 0001
>     10: 0000			    10: 0000
>     11: 0020			    11: 0000
>     12: 0000			    12: 0000
>     13: 0000			    13: 0000
>     14: 0000			    14: 0000
>     15: 9100			    15: dada
>     16: 0000			    16: 0000
>     17: 0000			    17: 0000
>     18: 0000			    18: 0000
>     19: 0000			    19: 00d8
>     20: 0000			    20: 0000
>     21: 0000			    21: 0000
>     22: 0022			    22: 0000
>     23: 0000			    23: 0000
>     24: 3210			    24: 3210
>     25: 7654			    25: 7654
>     26: 0000			    26: 0000
>     27: 8000			    27: 8000
>     28: 0000			    28: 0000
>     29: 0000			    29: 0000
>     30: 0000			    30: 0000
>     31: 0000			    31: 0000
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
