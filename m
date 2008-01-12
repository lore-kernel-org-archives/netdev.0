From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH for 2.6.24][NET] fs_enet: check for phydev existence in
 the ethtool handlers
Date: Sat, 12 Jan 2008 17:45:41 -0500
Message-ID: <47894315.6040705@garzik.org>
References: <20080108190555.GA23302@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57036 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759084AbYALWpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:45:44 -0500
In-Reply-To: <20080108190555.GA23302@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> Otherwise oops will happen if ethernet device has not been opened:
> 
> Unable to handle kernel paging request for data at address 0x0000014c
> Faulting instruction address: 0xc016f7f0
> Oops: Kernel access of bad area, sig: 11 [#1]
> MPC85xx
> NIP: c016f7f0 LR: c01722a0 CTR: 00000000
> REGS: c79ddc70 TRAP: 0300   Not tainted  (2.6.24-rc3-g820a386b)
> MSR: 00029000 <EE,ME>  CR: 20004428  XER: 20000000
> DEAR: 0000014c, ESR: 00000000
> TASK = c789f5e0[999] 'snmpd' THREAD: c79dc000
> GPR00: c01aceb8 c79ddd20 c789f5e0 00000000 c79ddd3c 00000000 c79ddd64 00000000
> GPR08: 00000000 c7845b60 c79dde3c c01ace80 20004422 200249fc 000002a0 100da728
> GPR16: 100c0000 00000000 00000000 00000000 20022078 00000009 200220e0 bfc85558
> GPR24: c79ddd3c 00000000 00000000 c02e0e70 c022fc64 ffffffff c7845800 bfc85498
> NIP [c016f7f0] phy_ethtool_gset+0x0/0x4c
> LR [c01722a0] fs_get_settings+0x18/0x28
> Call Trace:
> [c79ddd20] [c79dde38] 0xc79dde38 (unreliable)
> [c79ddd30] [c01aceb8] dev_ethtool+0x294/0x11ec
> [c79dde30] [c01aaa44] dev_ioctl+0x454/0x6a8
> [c79ddeb0] [c019b9d4] sock_ioctl+0x84/0x230
> [c79dded0] [c007ded8] do_ioctl+0x34/0x8c
> [c79ddee0] [c007dfbc] vfs_ioctl+0x8c/0x41c
> [c79ddf10] [c007e38c] sys_ioctl+0x40/0x74
> [c79ddf40] [c000d4c0] ret_from_syscall+0x0/0x3c
> Instruction dump:
> 81630000 800b0030 2f800000 419e0010 7c0803a6 4e800021 7c691b78 80010014
> 7d234b78 38210010 7c0803a6 4e800020 <8003014c> 7c6b1b78 38600000 90040004
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>
> ---
> 
> Just resending it, it feels like it got lost during holidays.
> 
>  drivers/net/fs_enet/fs_enet-main.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)

applied


