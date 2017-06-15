From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: assign default CPU port to all ports
Date: Thu, 15 Jun 2017 12:14:06 -0700
Message-ID: <b628d161-4c28-6e9f-0b34-09c676ed3653@gmail.com>
References: <20170615190654.5927-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cobham <jcobham@questertangent.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615190654.5927-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/15/2017 12:06 PM, Vivien Didelot wrote:
> The current code only assigns the default cpu_dp to all user ports of
> the switch to which the CPU port belongs. The user ports of the other
> switches of the fabric thus don't have a default CPU port.

Which would lead to a crash in dsa_master_netdev() :)

> 
> This patch fixes this by assigning the cpu_dp of all user ports of all
> switches of the fabric when the tree is fully parsed.
> 
> Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks for this fix:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
