From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: forcedeth oops
Date: Mon, 28 Jan 2008 10:31:48 -0500
Message-ID: <479DF564.5050803@nvidia.com>
References: <op.t5bx1p0fqw3wu1@titan> <479643E0.8070208@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Brooks <arb@sat.dundee.ac.uk>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:17689 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206AbYA2RIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 12:08:46 -0500
In-Reply-To: <479643E0.8070208@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jeff Garzik wrote:
> Andrew Brooks wrote:
>  > Hello
>  >
>  > I'm getting an oops in forcedeth whenever I shutdown, details below.
>  >
>  > I've tried kernel 2.6.16.59 and the latest forcedeth.c from nvidia.com
>  > which is package-1.23 version-0.62 date-2007/04/27.
>  >
>  > How can I download the latest forcedeth.c (including 2008-01-13 
> patches) ?
>  > It's not in the latest snapshot linux-2.6.24-rc8.
>  >
>  > Also, why is the version on nvidia.com not just older than the one in
>  > the kernel, but it appears to have forked back in May 2006.  Has there
>  > been independent development on each version?  They should be the same!
> 
> We don't run nvidia.com here :)
> 
> 
>  > Here's the diff:
>  > <  *    0.56: 22 Mar 2006: Additional ethtool and moduleparam support.
>  > <  *    0.57: 14 May 2006: Moved mac address writes to nv_probe and 
> nv_remove.
>  > <  *    0.58: 20 May 2006: Optimized rx and tx data paths.
>  > <  *    0.59: 31 May 2006: Added support for sideband management unit.
>  > <  *    0.60: 31 May 2006: Added support for recoverable error.
>  > <  *    0.61: 18 Jul 2006: Added support for suspend/resume.
>  > <  *    0.62: 16 Jan 2007: Fixed statistics, mgmt communication, and 
> low phy speed on S5.
>  > ---
>  >>  *    0.56: 22 Mar 2006: Additional ethtool config and moduleparam 
> support.
>  >>  *    0.57: 14 May 2006: Mac address set in probe/remove and order 
> corrections.
>  >>  *    0.58: 30 Oct 2006: Added support for sideband management unit.
>  >>  *    0.59: 30 Oct 2006: Added support for recoverable error.
>  >>  *    0.60: 20 Jan 2007: Code optimizations for rings, rx & tx data 
> paths, and stats.
>  >
>  >
>  > Here's the details of the oops:
>  > md: md0 switched to read-only mode.
>  > Unable to handle kernel NULL pointer dereference at virtual address 
> 00000000
>  > printing eip:
>  > f8ccdd55
>  > *pde = 36c6a001
>  > Oops: 0000 [#1]
>  > SMP
>  > Modules linked in: nvidia ... forcedeth ... sata_nv
>  > CPU: 1
>  > EIP:
>  > EFLAGS: 00010286 (2.6.16.59 #1)
>  > EIP is at nv_suspend+0x85/0x350 [forcedeth]
>  > eax:
>  > esi:
>  > ds:
>  > Process reboot
>  > Stack:
>  > Call Trace:
>  > show_stack_log
>  > show_registers
>  > die
>  > do_page_fault
>  > error_code
>  > nv_reboot_handler
>  > notifier_call_chain
>  > kernel_restart_prepare
>  > kernel_restart
>  > sys_reboot
>  > sysenter_past_esp
>  > Code: 8b 8c 3a 98 01 00 00 01 c8 8b ...
>  > INIT: no more processes left in this runlevel
> 
> Please reproduce this problem on a modern kernel (2.6.24-rc) without any
> closed source modules or drivers loaded.  Thanks.

Andrew,

The driver from the nvidia.com site was forked because we needed to 
create a backport driver package for older kernels. At some point, we 
need to converge the two branches again.

Let us know if you still have an issue with the latest kernel as Jeff 
mentioned.

Regards,
Ayaz


> 
>         Jeff
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
