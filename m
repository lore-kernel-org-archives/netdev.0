From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7222] New: sky2 throws a lot of "pci express
 error" in 2.6.18-mm2 on amd64
Date: Thu, 28 Sep 2006 09:22:42 -0700
Message-ID: <20060928092242.9cd44493.akpm@osdl.org>
References: <200609281210.k8SCAh9j005500@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	jackdachef@gmail.com, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:56756 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030247AbWI1QZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 12:25:49 -0400
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
In-Reply-To: <200609281210.k8SCAh9j005500@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 05:10:43 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7222
> 
>            Summary: sky2 throws a lot of "pci express error" in 2.6.18-mm2
>                     on amd64
>     Kernel Version: 2.6.18-mm2
>             Status: NEW
>           Severity: normal
>              Owner: acme@conectiva.com.br
>          Submitter: jackdachef@gmail.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.18-mm1
> Distribution: Gentoo Linux
> Hardware Environment: Asus P5W DH Deluxe
> Software Environment:
> Problem Description: kernel throws a lot of "pci express error"s
> 
> Steps to reproduce:
> compile in sky2 driver in amd64 kernel (2.6.18-mm2),
> boot into system => errors appear:
> 
> sky2 v1.9 addr 0xebdfc000 irq 19 Yukon-EC (0xb6) rev 2
> sky2 eth0: addr 00:17:31:e8:f3:53
> ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> PCI: Setting latency timer of device 0000:03:00.0 to 64
> sky2 v1.9 addr 0xebcfc000 irq 16 Yukon-EC (0xb6) rev 2
> sky2 eth1: addr 00:17:31:ee:e4:18
> [...]
> sky2 0000:04:00.0: pci express error (0x100407)
> [...]
> sky2 0000:03:00.0: pci express error (0x100407)
> [...]
> sky2 0000:04:00.0: pci express error (0x500547)
> sky2 0000:03:00.0: pci express error (0x500547)
> sky2 0000:04:00.0: pci express error (0x500547)
> sky2 0000:03:00.0: pci express error (0x500547)
> sky2 0000:04:00.0: pci express error (0x500547)
> sky2 0000:03:00.0: pci express error (0x500547)
> Losing some ticks... checking if CPU frequency changed.
> sky2 0000:04:00.0: pci express error (0x500547)
> sky2 0000:03:00.0: pci express error (0x500547)
> 
> this error occurs during the whole runtime of the kernel ...
> 
> I don't know if this severe, so I didn't let that kernel run long ...
> 
> network-functionality doesn't seem to be impaired:
> ping -c 3 www.google.com
> works & I can surf with links -g www.google.com
> 

I would be suspecting that something went wrong with "[PATCH] sky2: use
standard pci register capabilties for error register".
