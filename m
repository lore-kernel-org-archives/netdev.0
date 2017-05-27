From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle SERDES error
 appropriately
Date: Sat, 27 May 2017 18:57:37 -0400 (EDT)
Message-ID: <20170527.185737.283573150491511002.davem@davemloft.net>
References: <20170526220242.23353-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526220242.23353-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 26 May 2017 18:02:42 -0400

> mv88e6xxx_serdes_power returns an error, so no need to print an error
> message inside of it. Rather print it in its caller when the error is
> ignored, which is in the mv88e6xxx_port_disable void function.
> 
> Catch and return its error in the counterpart mv88e6xxx_port_enable.
> 
> Fixes: 04aca9938255 ("dsa: mv88e6xxx: Enable/Disable SERDES on port enable/disable")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
