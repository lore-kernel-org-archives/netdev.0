From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: dsa: setup master ethtool after dsa_ptr
Date: Tue, 19 Sep 2017 10:49:52 -0700
Message-ID: <85ebc3f7-b8b1-a2e4-f0e4-32c309857730@gmail.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
 <20170919155700.14474-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919155700.14474-4-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2017 08:56 AM, Vivien Didelot wrote:
> DSA overrides the master's ethtool ops so that we can inject its CPU
> port's statistics. Because of that, we need to setup the ethtool ops
> after the master's dsa_ptr pointer has been assigned, not before.

Yes, good point, technically this is a bugfix, but since we have changed
this quite often and the race is tiny, I am not positive we could a)
trigger this in real life, and b) provide a proper Fixes tag.

> 
> This patch setups the ethtool ops after dsa_ptr is assigned, and
> restores them before it gets cleared.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
