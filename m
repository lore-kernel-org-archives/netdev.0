From: Greg Fitzgerald <netzdamon@gmail.com>
Subject: Re: sky2 hangs
Date: Sat, 20 Sep 2008 17:18:23 -0400
Message-ID: <20080920211820.GA18095@betsy>
References: <20080920002324.GA3939@betsy> <20080919225310.429c9846@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:11510 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbYITVS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 17:18:28 -0400
Received: by rv-out-0506.google.com with SMTP id k40so977651rvb.1
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 14:18:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080919225310.429c9846@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10:53pm 09/19/08  , Stephen Hemminger wrote:
> On Fri, 19 Sep 2008 20:23:27 -0400
> Greg Fitzgerald <netzdamon@gmail.com> wrote:
> 
> > Hope I am sending this to the right place. Have the sky2 network card.
> > Internet will die out randomly, re-probing the sky2 module usually solves
> > the problem. According to dmesg the receiver is hanging.
> > 
> > sky2 eth0: hung mac 0:81 fifo 3 (86:89)
> > sky2 eth0: receiver hang detected
> > sky2 eth0: disabling interface
> > sky2 eth0: enabling interface
> > sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none
> > sky2 eth0: hung mac 0:11 fifo 194 (51:45)
> > sky2 eth0: receiver hang detected
> > 
> > This top half happens 3 or 4 times, then I'll start to get this extra
> > output in dmesg after that.
> > 
> > sky2 eth0: disabling interface
> > ACPI: PCI interrupt for device 0000:02:00.0 disabled
> > ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 19 (level, low) -> IRQ 19
> > PCI: Setting latency timer of device 0000:02:00.0 to 64
> > sky2 0000:02:00.0: v1.21 addr 0xcdefc000 irq 19 Yukon-EC (0xb6) rev 2
> > sky2 eth0: addr 00:17:31:9b:ca:89
> > sky2 eth0: enabling interface
> > sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none
> > sky2 eth0: disabling interface
> > sky2 eth0: enabling interface
> > sky2 eth0: Link is up at 10 Mbps, half duplex, flow control none
> > 
> > Some where in between all this, it actually gets to the point where I
> > totally loose my connection. Sometimes it will come back up and I'm
> > perfectly fine.
> > 
> > If I can provide any other information please let me know.
> > 
> > Oh, been having this problem for some time now. Current version of the
> > my kernel is 2.6.26.5.
> > 
> > --Greg
> 
> Haven't heard of this before. But since possibly a bad cable or PHY negotiation
> problem.  You might also check for firmware update from motherboard vendor.
> The message happens if a message gets stuck in the receive process and isn't
> making progress. Does it happen under load?  Is this really a half duplex 10mbit
> port or is it meant to be full duplex?

Cable is good, it was working just fine before on my 3com 905b, I did
plug it into my tester to be sure though. Motherboard has a tester that
should alert me as well. It's built into the bios. The nic port is full
duplex. Plugged directly into a westell wirespeed 2100 (ADSL Modem). Nic
is onboard, Asus P5DL2. I have the latest bios flashed from the website. 

As I said before its pretty random. I guess it does happen more often
under load though. Usually downloading a large iso is a quick way to
bring it down. It's not a sure thing though.

If there is any type of debugging I can do to provide more info would be
happy to do so.

Thanks.
