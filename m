From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: Incorrect use of phy_read_status()
Date: Tue, 07 Feb 2017 13:48:46 -0500 (EST)
Message-ID: <20170207.134846.1084414639114098837.davem@davemloft.net>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zefir.kurtisi@neratec.com,
        sebastian.hesselbarth@gmail.com, w-kwok2@ti.com,
        m-karicheri2@ti.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, tremyfr@gmail.com,
        sergei.shtylyov@cogentembedded.com, jszhang@marvell.com,
        jarod@redhat.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206235523.23216-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  6 Feb 2017 15:55:19 -0800

> This patch series removes incorrect uses of phy_read_status() which can clobber
> the PHY device link while we are executing with the state machine running.
> 
> greth was potentially another candidate, but it does funky stuff with
> auto-negotation that I am still trying to understand.

Series applied, thanks.
