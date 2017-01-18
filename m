From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: use cpu_switch instead of ds[0]
Date: Wed, 18 Jan 2017 12:38:21 -0800
Message-ID: <d686e94d-5055-b8e3-5436-842157b5f6ed@gmail.com>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
 <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
 <20170118125057.GB7690@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170118125057.GB7690@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/18/2017 04:50 AM, Andrew Lunn wrote:
> On Tue, Jan 17, 2017 at 08:41:39PM -0500, Vivien Didelot wrote:
>> Now that the DSA Ethernet switches are true Linux devices, the CPU
>> switch is not necessarily the first one. If its address is higher than
>> the second switch on the same MDIO bus, its index will be 1, not 0.
>>
>> Avoid any confusion by using dst->cpu_switch instead of dst->ds[0].
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
