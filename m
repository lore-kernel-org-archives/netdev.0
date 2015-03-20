From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ethernet: pcnet32: Setup the SRAM and NOUFLO
 on Am79C97{3,5}
Date: Fri, 20 Mar 2015 13:19:43 -0400 (EDT)
Message-ID: <20150320.131943.186301137261996820.davem@davemloft.net>
References: <20150319083704.GA31322@mchandras-linux.le.imgtec.org>
	<1426760894-2677-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	pcnet32@frontier.com
To: markos.chandras@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426760894-2677-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markos Chandras <markos.chandras@imgtec.com>
Date: Thu, 19 Mar 2015 10:28:14 +0000

> On a MIPS Malta board, tons of fifo underflow errors have been observed
> when using u-boot as bootloader instead of YAMON. The reason for that
> is that YAMON used to set the pcnet device to SRAM mode but u-boot does
> not. As a result, the default Tx threshold (64 bytes) is now too small to
> keep the fifo relatively used and it can result to Tx fifo underflow errors.
> As a result of which, it's best to setup the SRAM on supported controllers
> so we can always use the NOUFLO bit.
> 
> Cc: <netdev@vger.kernel.org>
> Cc: <stable@vger.kernel.org>
> Cc: <linux-kernel@vger.kernel.org>
> Cc: Don Fry <pcnet32@frontier.com>
> Signed-off-by: Markos Chandras <markos.chandras@imgtec.com>

Applied.
