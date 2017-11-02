From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/7] MIPS: Octeon: Add Free Pointer Unit (FPA) support.
Date: Wed, 1 Nov 2017 20:29:20 -0700
Message-ID: <d473b10c-ae5d-efa1-7329-de7b68152725@gmail.com>
References: <20171102003606.19913-1-david.daney@cavium.com>
 <20171102003606.19913-5-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        devicetree@vger.kernel.org, Carlos Munoz <cmunoz@cavium.com>
To: David Daney <david.daney@cavium.com>, linux-mips@linux-mips.org,
        ralf@linux-mips.org, James Hogan <james.hogan@mips.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171102003606.19913-5-david.daney@cavium.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 11/01/17 à 17:36, David Daney a écrit :
> From: Carlos Munoz <cmunoz@cavium.com>
> 
> From the hardware user manual: "The FPA is a unit that maintains
> pools of pointers to free L2/DRAM memory. To provide QoS, the pools
> are referenced indirectly through 1024 auras. Both core software
> and hardware units allocate and free pointers."

This looks like a possibly similar implement to what
drivers/net/ethernet/marvell/mvneta_bm.c, can you see if you can make
any use of genpool_* and include/net/hwbm.h here as well?
-- 
Florian
