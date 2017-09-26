From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v2] net: dsa: mv88e6xxx: lock mutex when freeing IRQs
Date: Tue, 26 Sep 2017 12:05:36 -0700
Message-ID: <1881d3da-0db8-c581-30de-a1dae20ceeaf@gmail.com>
References: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/26/2017 11:57 AM, Vivien Didelot wrote:
> mv88e6xxx_g2_irq_free locks the registers mutex, but not
> mv88e6xxx_g1_irq_free, which results in a stack trace from
> assert_reg_lock when unloading the mv88e6xxx module. Fix this.
> 
> Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
