From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [lkp] [net]  af1fee9821:
 BUG:spinlock_trylock_failure_on_UP_on_CPU
Date: Mon, 7 Nov 2016 10:31:48 +0100
Message-ID: <20161107093148.GA27001@lunn.ch>
References: <20161107022628.GA21529@yexl-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Allan W. Nielsen" <allan.nielsen@microsemi.com>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        lkp@01.org
To: kernel test robot <xiaolong.ye@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161107022628.GA21529@yexl-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 07, 2016 at 10:26:28AM +0800, kernel test robot wrote:
> 
> FYI, we noticed the following commit:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> commit af1fee98219992ba2c12441a447719652ed7e983 ("net: phy: Add support for Microsemi VSC 8530/40 Fast Ethernet PHY")

Humm, interesting. I've no idea how this patch can trigger such a
warning. The USB gadget does not have an Ethernet PHY, let alone a
Microsemi 8530/40 Fast Ethernet PHY this patch adds.

However, it seems nicely documented how to reproduce this. Allan, can
you setup such a system? Reproduce it, then revert the change and see
if it still happens.

   Andrew
