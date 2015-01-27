From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa/mv88e6xxx: add reg read and write debug
Date: Tue, 27 Jan 2015 00:04:30 -0800 (PST)
Message-ID: <20150127.000430.1352169065847404927.davem@davemloft.net>
References: <1422047436-6864-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422047436-6864-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 23 Jan 2015 16:10:36 -0500

> This commit adds debug messages for the generic mv88e6xxx read and write
> routines. The output is similar to this:
> 
>     mdio-gpio mdio-gpio.0: <- addr: 0x1b reg: 0x05 val: 0x4000
>     mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x07 val: 0x3113
>     mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x08 val: 0x0330
>     mdio-gpio mdio-gpio.0: -> addr: 0x1b reg: 0x09 val: 0x0000
> 
> This is convenient to dynamically debug operations through debugfs with:
> 
>     echo file mv88e6xxx.c +p > <debugfs>/dynamic_debug/control
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
