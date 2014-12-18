From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fixed TPACKET V3 to signal poll when block is closed
 rather than for every packet
Date: Wed, 17 Dec 2014 23:37:29 -0500 (EST)
Message-ID: <20141217.233729.323289791259636663.davem@davemloft.net>
References: <14a5a65c372.fa01df65100787.352762707968323665@dcollins.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dan@dcollins.co.nz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <14a5a65c372.fa01df65100787.352762707968323665@dcollins.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Collins <dan@dcollins.co.nz>
Date: Thu, 18 Dec 2014 12:36:56 +1300


> Make TPACKET_V3 signal poll when block is closed rather than for every packet. Side effect is that poll will be signaled when block retire timer expires which didn't previously happen. Issue was visible when sending packets at a very low frequency such that all blocks are retired before packets are received by TPACKET_V3. This caused avoidable packet loss. The fix ensures that the signal is sent when blocks are closed which covers the normal path where the block is filled as well as the path where the timer expires. The case where a block is filled without moving to the next block (ie. all blocks are full) will still cause poll to be signaled.

Please format your commit messages to 80 column ascii formatted text.

> Signed-off-by: Dan Collins &lt;dan@dcollins.co.nz&gt;

You need real "<" and ">" characters here.
