From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: dsa: mv88e6xxx: lock mutex when freeing
 IRQs
Date: Thu, 28 Sep 2017 10:29:07 -0700 (PDT)
Message-ID: <20170928.102907.1277678452927871516.davem@davemloft.net>
References: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926185721.12187-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 26 Sep 2017 14:57:21 -0400

> mv88e6xxx_g2_irq_free locks the registers mutex, but not
> mv88e6xxx_g1_irq_free, which results in a stack trace from
> assert_reg_lock when unloading the mv88e6xxx module. Fix this.
> 
> Fixes: 3460a5770ce9 ("net: dsa: mv88e6xxx: Mask g1 interrupts and free interrupt")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied and queued up for -stable.
