From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: via-velocity: printk of dev->name before name has been allocated
Date: Sun, 22 Feb 2009 12:08:02 +0100
Message-ID: <49A13212.2050400@computer.org>
References: <49A04E4B.7080207@computer.org> <20090221.235152.144560236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:58845 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753377AbZBVLKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 06:10:18 -0500
Received: from [192.168.1.4] (athloroad.xperim.be [192.168.1.4])
	(authenticated bits=0)
	by via.xperim.be (8.14.1/8.14.1/Debian-8ubuntu1) with ESMTP id n1MB829J029813
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 12:08:04 +0100
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

OK, found the commit (07b5f6a6fd0ce47390f7fbec966cd5c70127e597). Sorry 
to have bothered you.

