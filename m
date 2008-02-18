From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Linux 2.6.24.1  - kernel does not boot; IRQ trouble?
Date: Mon, 18 Feb 2008 05:00:49 -0800
Message-ID: <20080218050049.12bcc596.akpm@linux-foundation.org>
References: <23590.97305.qm@web52910.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46894 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760781AbYBRNBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 08:01:53 -0500
In-Reply-To: <23590.97305.qm@web52910.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Feb 2008 00:54:08 +0000 (GMT) Chris Rankin <rankincj@yahoo.com> wrote:

> [Try this again, except this time I'll force the attachment as inline text!]
> 
> Hi,
> 
> I have managed to boot 2.6.24.1 on this machine, with the NMI watchdog enabled, by using the
> "acpi=noirq" option. (There does seem to be some unhappiness with bridge symlinks in sysfs,
> though.)
> 
> ...
>
> sysfs: duplicate filename 'bridge' can not be created
> WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> Pid: 1, comm: swapper Not tainted 2.6.24.1 #1
>  [<c0105020>] show_trace_log_lvl+0x1a/0x2f
>  [<c0105990>] show_trace+0x12/0x14
>  [<c010613d>] dump_stack+0x6c/0x72
>  [<c01991bf>] sysfs_add_one+0x57/0xbc
>  [<c0199e41>] sysfs_create_link+0xc2/0x10d
>  [<c01bae9a>] pci_bus_add_devices+0xbd/0x103
>  [<c034016c>] pci_legacy_init+0x56/0xe3
>  [<c03274e1>] kernel_init+0x157/0x2c3
>  [<c0104c83>] kernel_thread_helper+0x7/0x10
>  =======================
> pci 0000:00:01.0: Error creating sysfs bridge symlink, continuing...
> sysfs: duplicate filename 'bridge' can not be created
> WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> Pid: 1, comm: swapper Not tainted 2.6.24.1 #1
>  [<c0105020>] show_trace_log_lvl+0x1a/0x2f
>  [<c0105990>] show_trace+0x12/0x14
>  [<c010613d>] dump_stack+0x6c/0x72
>  [<c01991bf>] sysfs_add_one+0x57/0xbc
>  [<c0199e41>] sysfs_create_link+0xc2/0x10d
>  [<c01bae9a>] pci_bus_add_devices+0xbd/0x103
>  [<c01bae82>] pci_bus_add_devices+0xa5/0x103
>  [<c034016c>] pci_legacy_init+0x56/0xe3
>  [<c03274e1>] kernel_init+0x157/0x2c3
>  [<c0104c83>] kernel_thread_helper+0x7/0x10
>  =======================

I have a vague feeling that this was fixed, perhaps in 2.6.24.x?
