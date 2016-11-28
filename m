From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net-next 0/5] Support Armada 37xx SoC (ARMv8 64-bits) in
 mvneta driver
Date: Mon, 28 Nov 2016 16:40:49 +0800
Message-ID: <20161128164049.77137347@xhacker>
References: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        "Sebastian Hesselbarth" <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        <linux-arm-kernel@lists.infradead.org>,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:54576 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752805AbcK1Ip6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 03:45:58 -0500
In-Reply-To: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gregory,

On Fri, 25 Nov 2016 16:30:13 +0100 Gregory CLEMENT wrote:

> Hi,
> 
> The Armada 37xx is a new ARMv8 SoC from Marvell using same network
> controller as the older Armada 370/38x/XP SoCs. This series adapts the
> driver in order to be able to use it on this new SoC. The main changes
> are:
> 
> - 64-bits support: the first patches allow using the driver on a 64-bit
>   architecture.
> 
> - MBUS support: the mbus configuration is different on Armada 37xx
>   from the older SoCs.
> 
> - per cpu interrupt: Armada 37xx do not support per cpu interrupt for
>   the NETA IP, the non-per-CPU behavior was added back.
> 
> The first item is solved by patches 1 to 3.
> The 2 last items are solved by patch 4.
> In patch 5 the dt support is added.
> 
> Beside Armada 37xx, the series have been tested on Armada XP and
> Armada 38x (with Hardware Buffer Management and with Software Buffer
> Managment).

AFAICT, this is a V2? seems no Change log ;)

Thanks,
Jisheng
