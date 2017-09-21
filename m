From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: use dedicated CPU port
Date: Wed, 20 Sep 2017 22:10:27 -0700
Message-ID: <dfdca859-6ecd-d632-a0c4-11e890d2de52@gmail.com>
References: <20170920162805.29503-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920162805.29503-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/20/2017 09:28 AM, Vivien Didelot wrote:
> Each port in DSA has its own dedicated CPU port currently available in
> its parent switch's ds->ports[port].cpu_dp. Use it instead of getting
> the unique tree CPU port, which will be deprecated soon.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/b53/b53_common.c | 4 ++--
>  drivers/net/dsa/bcm_sf2.c        | 6 +++---
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
