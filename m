From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SolutionEngine7724: fix Ether support
Date: Tue, 20 Aug 2013 17:05:29 -0700 (PDT)
Message-ID: <20130820.170529.2112928097086306489.davem@davemloft.net>
References: <201308180213.23296.sergei.shtylyov@cogentembedded.com>
	<201308180219.09528.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308180219.09528.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 18 Aug 2013 02:19:09 +0400

> The Ether platform data is behind the declaration of 'struct sh_eth_plat_data'
> as it's lacking the initializers for the 'register_type' and 'phy_interface'
> fields -- it means they'll be implicitly and wrongly set to SH_ETH_REG_GIGABIT
> and PHY_INTERFACE_MODE_NA. Initialize the fields explicitly and fix off-by-one
> error in the Ether memory resource end, while at it...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
