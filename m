From: David Miller <davem@davemloft.net>
Subject: Re: [v1 0/6] *** nps_enet fixups ***
Date: Mon, 17 Aug 2015 22:26:20 -0700 (PDT)
Message-ID: <20150817.222620.475853456939322841.davem@davemloft.net>
References: <1439791119-26892-1-git-send-email-noamc@ezchip.com>
	<20150817.103607.1737876155019074073.davem@davemloft.net>
	<DB4PR02MB2725A45B664C42E3AB7B98ED6780@DB4PR02MB272.eurprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com, talz@ezchip.com
To: noamc@ezchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DB4PR02MB2725A45B664C42E3AB7B98ED6780@DB4PR02MB272.eurprd02.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noam Camus <noamc@ezchip.com>
Date: Tue, 18 Aug 2015 05:04:20 +0000

> I followed "Hardware Architecture" section from:
> http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
> and came up with "reduce processing latency" idea.

That document has lots of incorrect advice, that's for sure.

For one thing, it also says to count TX work against the budget, you
absolutely should not do this.  TX work is "free" compared to RX work
(which is several orders of magnitude more expensive) and therefore
should not count against the NAPI budget value.
