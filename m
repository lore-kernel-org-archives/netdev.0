From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] et131x: Fix logical vs bitwise check in
 et131x_tx_timeout()
Date: Sat, 16 Jul 2016 22:04:44 -0700 (PDT)
Message-ID: <20160716.220444.1385583329528724015.davem@davemloft.net>
References: <1468626024-31534-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mark.einon@gmail.com, andrew@lunn.ch,
	a@unstable.cc, felipe.balbi@linux.intel.com, fw@strlen.de,
	wuninsu@gmail.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468626024-31534-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Jul 2016 16:40:22 -0700

> We should be using a logical check here instead of a bitwise operation
> to check if the device is closed already in et131x_tx_timeout().
> 
> Reported-by: coverity (CID 146498)
> Fixes: 38df6492eb511 ("et131x: Add PCIe gigabit ethernet driver et131x to drivers/net")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
