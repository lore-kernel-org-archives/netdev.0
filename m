From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC v2] virtio: add virtio-over-PCI driver
Date: Tue, 14 Apr 2009 15:45:14 -0600
Message-ID: <fa686aa40904141445x6a125e12r391e0853d89baf72@mail.gmail.com>
References: <20090224000002.GA578@ovro.caltech.edu> <fa686aa40904141328oa57fb1bsffd0549a52eca90@mail.gmail.com>
	<49E4FED0.1020003@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ira Snyder <iws@ovro.caltech.edu>, Arnd Bergmann <arnd@arndb.de>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Hawkins <dwh@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:19584 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbZDNVpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 17:45:30 -0400
In-Reply-To: <49E4FED0.1020003@ovro.caltech.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2009 at 3:23 PM, David Hawkins <dwh@ovro.caltech.edu> wrote:
> I'll let Ira update you on the patch status.
>
> If you want someone to chat about the hardware-level interaction,
> feel free to chat off-list - assuming of course that no one wants
> to hear us talk hardware :)
>
> I selected the MPC8349EA in-part due to its PCI mailboxes, so
> that we could implement this type of driver (an interlocked
> handshake for flow control of data transfers). The previous
> chip I'd used was a PLX PCI9054 Master/Target, and it has
> similar registers.
>
> I'm not sure if the Xilinx PCI core, or whatever PCI core you
> are using, already has something like the mailboxes implemented,
> but if not, it won't take much to code up some logic.
> I prefer VHDL myself, but can speak Verilog if forced to :)

Thanks David.  I haven't looked closely at the xilinx pci data sheet
yet, but I don't expect too many issues in this area.  As you say, it
won't take much to code it up.  I'll be poking my VHDL engineer to
make it do what I want it to.  :-)

I'll keep you up to date on my progress.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
