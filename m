From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fixed TPACKET V3 to signal poll when block is closed
 rather than for every packet
Date: Thu, 18 Dec 2014 16:51:38 -0500 (EST)
Message-ID: <20141218.165138.2005282332695465620.davem@davemloft.net>
References: <1418939356.3016.9.camel@voodoo.cms.waikato.ac.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dan@dcollins.co.nz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418939356.3016.9.camel@voodoo.cms.waikato.ac.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Collins <dan@dcollins.co.nz>
Date: Fri, 19 Dec 2014 10:49:16 +1300

> Make TPACKET_V3 signal poll when block is closed rather than for every
> packet. Side effect is that poll will be signaled when block retire
> timer expires which didn't previously happen. Issue was visible when
> sending packets at a very low frequency such that all blocks are retired
> before packets are received by TPACKET_V3. This caused avoidable packet
> loss. The fix ensures that the signal is sent when blocks are closed
> which covers the normal path where the block is filled as well as the
> path where the timer expires. The case where a block is filled without
> moving to the next block (ie. all blocks are full) will still cause poll
> to be signaled. 
> 
> Signed-off-by: Dan Collins <dan@dcollins.co.nz>

Your email client has corrupted the patch, turning TAB characters into
sequences of SPACE characters.

Please turn off all formatting in your email client, read:

	Documentation/email-clients.txt

for help.
