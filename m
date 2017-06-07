From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/5] net: dsa: add CPU and DSA ports as VLAN
 members
Date: Wed, 7 Jun 2017 12:38:16 -0700
Message-ID: <2e49ee11-3ced-3838-c939-4eb847d3fb1e@gmail.com>
References: <20170606205631.22880-1-vivien.didelot@savoirfairelinux.com>
 <20170606205631.22880-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606205631.22880-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2017 01:56 PM, Vivien Didelot wrote:
> In a multi-chip switch fabric, it is currently the responsibility of the
> driver to add the CPU or DSA (interconnecting chips together) ports as
> members of a new VLAN entry. This makes the drivers more complicated.
> 
> We want the DSA drivers to be stupid and the DSA core being the one
> responsible for caring about the abstracted switch logic and topology.
> 
> Make the DSA core program the CPU and DSA ports as part of the VLAN.
> 
> This makes all chips of the data path to be aware of VIDs spanning the
> the whole fabric and thus, seamlessly add support for cross-chip VLAN.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
