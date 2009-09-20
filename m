From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: sky2 rx length errors
Date: Sat, 19 Sep 2009 23:35:36 -0700
Message-ID: <20090919233536.f5fb700c.akpm@linux-foundation.org>
References: <c5bd819b0909180641n7c353b80tc15b9c9fe02d5c95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Grozdan <neutrino8@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43274 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750797AbZITGgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 02:36:05 -0400
In-Reply-To: <c5bd819b0909180641n7c353b80tc15b9c9fe02d5c95@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(added cc's from the MAINTAINERS file)

On Fri, 18 Sep 2009 15:41:45 +0200 Grozdan <neutrino8@gmail.com> wrote:

> Hi,
> 
> I have a Marvell onboard NIC (88E8053) and I've been noticing for a
> while now a bit weird behavior with the sky2 driver. This mostly
> occurs with newer kernels (2.6.30, 2.6.31) and my older distro kernel
> (2.6.27.21) does not seem to have the same problem. Basically, the
> sky2 driver will randomly and unpredictably spew rx length error
> messages and reboot itself. I also noticed in dmesg that this mostly
> occurs after "martian destination" messages. After this message, sky2
> starts spewing messages as shown below and then reboots itself. It is
> not really a big problem for me, but since I'm virtually always logged
> in in IRC, the client always loses connection, waits for a few minutes
> to get a response from the server and then relogs me again. I do not
> think it's a HW problem as the Marvell NIC otherwise works perfectly
> and I've checked my cable modem too which operates without a problem.
> Any ideas?
> 
> PS: please cc me as I'm not subscribed to the mailing list
> 
> sky2 driver version 1.23
> sky2 0000:05:00.0: PCI INT A -> GSI 36 (level, low) -> IRQ 36
> sky2 0000:05:00.0: setting latency timer to 64
> sky2 0000:05:00.0: PCI: Disallowing DAC for device
> sky2 0000:05:00.0: Yukon-2 EC chip revision 2
> sky2 0000:05:00.0: irq 53 for MSI/MSI-X
> sky2 0000:05:00.0: No interrupt generated using MSI, switching to INTx mode.
> sky2 eth0: addr 00:11:d8:a1:5b:0e
> sky2 eth0: enabling interface
> sky2 eth0: Link is up at 100 Mbps, full duplex, flow control rx
> .....
> .....
> martian destination 0.0.0.0 from 172.23.204.1, dev eth0
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x5ea0100 length 598
> sky2 eth0: rx length error: status 0x5ea0100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x5ea0100 length 598
> sky2 eth0: rx length error: status 0x5ea0100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598
> sky2 eth0: rx length error: status 0x4420100 length 598

