From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: APIC error on 32-bit kernel
Date: Tue, 27 Mar 2007 14:42:20 -0600
Message-ID: <m14po6xvtf.fsf@ebiederm.dsl.xmission.com>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35077 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965417AbXC0Umg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 16:42:36 -0400
In-Reply-To: <20070323200817.1f3e39b9@osprey.hogchain.net> (Jay Cliburn's
	message of "Fri, 23 Mar 2007 20:08:17 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn <jacliburn@bellsouth.net> writes:

> We're trying to track down the source of a problem that occurs whenever
> the atl1 network driver is activated on a 32-bit 2.6.21-rc4 kernel.  We
> need help from netdev.
>
> We can load the driver just fine, but whenever we activate the
> network, we see APIC errors (a sample of them are shown here,
> captured from a serial console):

Do you have msi's working in 2.6.21-rc4 in the x86_64 kernel?

[snip nasty apic errors]

> The machine hangs for about 5-10 seconds, then spontaneously reboots
> without further console output.
>
> This is an Asus M2V (Via K8T890) motherboard.
>
> The problem does not occur on a 32-bit kernel if we boot with
> pci=nomsi, and it doesn't occur at all on a 64-bit kernel on the same
> motherboard.

Ok.

My first guess is going to be that something different in the 64bit
and 32bit kernels.  Either MSI support or how the MSI are setup or
some bug work around.

A lot of that code is pretty common so...

> We also do not see this problem on Intel-based motherboards, with
> either 32- or 64-bit kernels.

Can you confirm MSI is enabled in those kernels as well?

> We'd appreciate any pointers to get this solved.  Full error text,
> dmesg (with atl1 device disabled), lspci, and /proc/interrupts attached.

Thanks.

Eric
