From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: skge ethernet breakage (PCI: Unable to reserve mem region)
Date: Tue, 11 Sep 2007 10:21:10 +0200
Message-ID: <20070911102110.1f32fa7e@oldman>
References: <1189183355.3784.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Gukelberger <g.u.g.i@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56893 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760614AbXIKIUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 04:20:30 -0400
In-Reply-To: <1189183355.3784.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 07 Sep 2007 18:42:35 +0200
Jan Gukelberger <g.u.g.i@gmx.de> wrote:

> Hi,
> 
> I originally reported this bug to the Debian BTS:
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=441232
> There I was told to talk directly to upstream.
> 
> I am pasting the original bug report below. The referenced text files
> can be found at the mentioned BTS URL. 
> Additionally, I have just tried Linux 2.6.23-rc5 and am attaching the
> corresponding dmesg output.
> 
> Thanks in advance for any help,
> Jan
> 
> 
> With recent kernels my on-board network adapter does not work any more.
> This is a Marvell Gigabit Ethernet Controller on an Asus P5B-V
> mainboard.
> 
> This is the same bug as #428452 reported earlier against
> linux-image-2.6.21-1-amd64. (Sorry for the duplicate, I didn't know how
> to extend the old report to newer kernel versions.)
> In fact, the network adapter hasn't been working since then, i.e. the
> last working kernel image was 2.6.20-1-amd64 (which I am using now). The
> following images 2.6.2[12]-[12]-amd64 have all exposed the same problem.
> 
> The key problem seem to be the following lines in dmesg:
> ------------------------------------------------------------------------
> ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
> PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
> skge 0000:04:04.0: cannot obtain PCI resources
> ACPI: PCI interrupt for device 0000:04:04.0 disabled
> skge: probe of 0000:04:04.0 failed with error -16
> ------------------------------------------------------------------------
> 
> I'm attaching full 'dmesg' output from working (2.6.20-1) and broken
> (2.6.22-2) kernel versions as well as the output of 'lspci -vvv' on the
> most recent kernel.
> 
> If you need any other information or I can try something please let me
> know.

There is some kind of device conflict, please provide lspci -vvvxx output.
