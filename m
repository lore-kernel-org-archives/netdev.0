From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: make slave close symmetrical to
 open
Date: Fri, 22 Sep 2017 10:15:21 -0700
Message-ID: <4bab03d6-40e8-1009-8f70-e39baab908f5@gmail.com>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922161753.19563-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/22/2017 09:17 AM, Vivien Didelot wrote:
> The DSA slave open function configures the unicast MAC addresses on the
> master device, enable the switch port, change its STP state, then start
> the PHY device.
> 
> Make the close function symmetric, by first stopping the PHY device,
> then changing the STP state, disabling the switch port and restore the
> master device.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
