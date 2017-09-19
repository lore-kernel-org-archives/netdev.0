From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: dsa: setup master ethtool
 unconditionally
Date: Tue, 19 Sep 2017 10:48:17 -0700
Message-ID: <f196c2f4-67a1-a0ed-8a38-92893b20735b@gmail.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
 <20170919155700.14474-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2017 08:56 AM, Vivien Didelot wrote:
> When a DSA switch tree is meant to be applied, it already has a CPU
> port. Thus remove the condition of dst->cpu_dp.
> 
> Moreover, the next lines access dst->cpu_dp unconditionally.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
