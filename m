From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: via-velocity: printk of dev->name before name has been allocated
Date: Sun, 22 Feb 2009 09:43:05 +0100
Message-ID: <49A11019.6050400@computer.org>
References: <49A04E4B.7080207@computer.org> <20090221.235152.144560236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:57433 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbZBVIoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:44:38 -0500
In-Reply-To: <20090221.235152.144560236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> I have the following in dmesg:
>>
>> [   21.212838] VIA Networking Velocity Family Gigabit Ethernet Adapter Driver Ver. 1.14
>> [   21.212847] Copyright (c) 2002, 2003 VIA Networking Technologies, Inc.
>> [   21.212852] Copyright (c) 2004 Red Hat Inc.
>> [   21.212885] ACPI: PCI Interrupt 0000:00:0e.0[A] -> GSI 18 (level, low) -> IRQ 17
>> [   21.212937] eth%d: set value of parameter Interrupt service works to 64
>> [   21.213684] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter
>> [   21.213691] eth0: Ethernet Address: 00:40:63:F4:AF:DE
> 
> This is already fixed in current kernels.
> 
> Reporting such things against 6 release old kernels is very near to
> pointless, please check against current releases first next time.

Ooh, excuse me!

As I wrote I did look at current git net-2.6 and thought the issue was 
still there. That was based on looking at the code though; I can't run a 
current kernel on that machine.

You guys ar going to have to get better at communicating with your user 
base...

