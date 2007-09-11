From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: skge ethernet breakage (PCI: Unable to reserve mem region)
Date: Tue, 11 Sep 2007 14:37:01 +0200
Message-ID: <20070911143701.628c8d18@oldman>
References: <1189183355.3784.11.camel@localhost>
	<20070911102110.1f32fa7e@oldman>
	<1189508304.4069.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Gukelberger <g.u.g.i@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:32894 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965294AbXIKMgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 08:36:20 -0400
In-Reply-To: <1189508304.4069.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 12:58:24 +0200
Jan Gukelberger <g.u.g.i@gmx.de> wrote:

> On Tue, 2007-09-11 at 10:21 +0200, Stephen Hemminger wrote:
> > On Fri, 07 Sep 2007 18:42:35 +0200
> > Jan Gukelberger <g.u.g.i@gmx.de> wrote:
> [...]
> > > The key problem seem to be the following lines in dmesg:
> > > ------------------------------------------------------------------------
> > > ACPI: PCI Interrupt 0000:04:04.0[A] -> GSI 19 (level, low) -> IRQ 19
> > > PCI: Unable to reserve mem region #1:4000@ff9f8000 for device 0000:04:04.0
> > > skge 0000:04:04.0: cannot obtain PCI resources
> > > ACPI: PCI interrupt for device 0000:04:04.0 disabled
> > > skge: probe of 0000:04:04.0 failed with error -16
> > > ------------------------------------------------------------------------
> > > 
> > 
> > There is some kind of device conflict, please provide lspci -vvvxx output.
> 
> I'm attaching the output of 'lspci -vvvxx' on the working 2.6.20 kernel
> as well as the output of 'lspci -vvxxx' on 2.6.23-rc5 which I recorded
> earlier.
> I you specifically need 'lspci -vvvxx' on 2.6.23-rc5 please drop me a
> note and I'll reboot quickly.
> 
> Thanks,
> Jan

All looks in order, on the PCI tables. There is a firewire control just
above the skge device, perhaps you enabled one of the firewire stacks
in the configuration?  Perhaps the console (dmesg) output will show some clue.
