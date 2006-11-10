From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 4/4] skge: version 1.9
Date: Thu, 09 Nov 2006 16:47:57 -0800
Message-ID: <200611100047.kAA0lvZt002542@death.nxdomain.ibm.com>
References: <20061005224949.456192755@osdl.org> <20061005225209.769741968@osdl.org> <20061107132506.GS2667@mathom.us> <200611072028.kA7KSQZt032181@death.nxdomain.ibm.com> <20061110003448.GE2667@mathom.us>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41907 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965765AbWKJAsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 19:48:02 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAA0lw7j023897
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 19:47:58 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAA0lwGI291710
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 19:47:58 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAA0lwZ3028752
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 19:47:58 -0500
To: Michael Stone <mstone@mathom.us>
In-reply-to: <20061110003448.GE2667@mathom.us> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <mstone@mathom.us> wrote:

>On Tue, Nov 07, 2006 at 12:28:26PM -0800, Jay Vosburgh wrote:
>>	Can you provide some bonding configuration details?  Which mode,
>>options, etc, as well as the relevant bits from dmesg (you can send it
>> to me privately if it's huge)?
>
>I think I sent another message that I'm just doing ifenslave bond0 eth2
>ifenslave bond0 eth3 with no particular options set.

	I was thinking of the options to the bonding driver (probably in
the network configuration or /etc/modprobe.conf); a reasonable set of
information is in /proc/net/bonding/bond0, so that's a good place to
start, along with whatever "uname -a" prints (kernel version,
architecture, mostly).

[...] The application is a network sniffer, and
>the cards are forced to 1000Mbps/full duplex because the other end doesn't
>negotiate. What's the relevant part of dmesg?

	Well, pretty much anything from the bonding driver or the
ethernet driver.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
