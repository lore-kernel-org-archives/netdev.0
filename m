From: John Zielinski <john_ml@undead.cc>
Subject: Re: RTL 8139 stops RX after receiving a jumbo frame
Date: Sun, 26 Feb 2006 16:12:16 -0500
Message-ID: <440219B0.6080301@undead.cc>
References: <44012D53.30700@undead.cc> <1140957965.23286.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751404AbWBZVMT@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1140957965.23286.9.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Should drop the packet, but it may be triggering a driver path with a
> bug. Is this repeatable and with multiple 8139 cards
>   
I took the card out of my firewall and put it into my test box.  The
test procedure was to ping a third machine from the text box and then
start pinging the test box from the second machine using large packets.
The rev K card would always stop receiving permanently until a
ifdown/ifup was done.

I tried three other cards and they only showed heavy packet loss from
the ping running on the test box.  The packet loss went away when the
second machine stopped pinging it with the large packets.

Here's the list of cards:

Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
Subsystem: Realtek Semiconductor Co., Ltd. RT8139
eth0:  Identified 8139 chip type 'RTL-8139 rev K'

Ethernet controller: Accton Technology Corporation SMC2-1211TX (rev 10)
Subsystem: Accton Technology Corporation EN-1207D Fast Ethernet Adapter
eth0:  Identified 8139 chip type 'RTL-8139B'

Ethernet controller: D-Link System Inc RTL8139 Ethernet (rev 10)
Subsystem: D-Link System Inc DFE-538TX 10/100 Ethernet Adapter
eth0:  Identified 8139 chip type 'RTL-8139C'

Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
Subsystem: Realtek Semiconductor Co., Ltd. RT8139
eth0:  Identified 8139 chip type 'RTL-8139C'
