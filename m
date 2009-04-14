From: Avi Kivity <avi@redhat.com>
Subject: Re: 2.6.30-rc1 A few issues and a stall
Date: Tue, 14 Apr 2009 13:03:58 +0300
Message-ID: <49E45F8E.9080803@redhat.com>
References: <200904121124.07193.edt@aei.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org
To: Ed Tomlinson <edt@aei.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34005 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756365AbZDNKDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 06:03:38 -0400
In-Reply-To: <200904121124.07193.edt@aei.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ed Tomlinson wrote:
> Once the above networking stuff is setup I start kvm with the command below
>
> QEMU_AUDIO_DRV=alsa kvm -m 1024 -cdrom /mnt/sdc4/divx/archlinux-2009.02-ftp-i686.iso -boot c -smp 3 -usb -usbdevice tablet -vga std -drive file=arch.img -net nic,macaddr=52:54:00:12:34:23 -net tap,ifname=qtap0,script=no -soundhw all -mem-path /hugepages
>
> which works and the kvm session boots just fine.  
>
> Issue 2.  When I attempt to ping outside the kvm session the pc (not just the kvm session) hangs.
> Its impossible to kill the kvm session and there are numerious info messages from RCU (tree RCU enabled)
> about stalls.  
>   

The rcu messages are likely because a processor has died.

Do things work if you drop -mem-path?

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

