From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix setup of port control 1
Date: Mon, 20 Apr 2015 22:01:53 -0400 (EDT)
Message-ID: <20150420.220153.1027836111884807798.davem@davemloft.net>
References: <1429564763-10098-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<20150420230507.GC32294@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	linux@roeck-us.net, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150420230507.GC32294@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 21 Apr 2015 01:05:07 +0200

> On Mon, Apr 20, 2015 at 05:19:23PM -0400, Vivien Didelot wrote:
>> mv88e6xxx_setup_port_common was writing to PORT_DEFAULT_VLAN (port
>> offset 0x07) instead of PORT_CONTROL_1 (port offset 0x05).
> 
> Hi Vivien
> 
> Good catch.
>  
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Fixes: cca8b1337541 ("net: dsa: Use mnemonics rather than register numbers")
> Acked-by: Andrew Lunn <andrew@lunn.ch>

Applied.
