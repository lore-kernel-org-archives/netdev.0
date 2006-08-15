From: Michael Stone <mstone@mathom.us>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Tue, 15 Aug 2006 09:18:54 -0400
Message-ID: <20060815131852.GP2900@mathom.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:43938 "EHLO
	vms044pub.verizon.net") by vger.kernel.org with ESMTP
	id S1030239AbWHONTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 09:19:24 -0400
Received: from osgiliath.mathom.us ([72.66.19.42])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J41003WEJNSRRP2@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 15 Aug 2006 08:19:05 -0500 (CDT)
To: netdev@vger.kernel.org
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hopefully the skge driver will be updated to support everything the 
sk98lin driver does before it is removed. Among other things, I don't 
see any documentation for the skge driver similar to that for the 
sk98lin driver. Is there some driver option to use both ports of a dual 
port card, as there was for the sk98lin module?

I tried testing the skge driver on one system and got this in dmesg:

skge 0000:03:0c.0: unsupported phy type 0x0
ACPI: PCI interrupt for device 0000:03:0c.0 disabled
skge: probe of 0000:03:0c.0 failed with error -95

the sk98lin driver says:

eth0: SysKonnect SK-NET Gigabit Ethernet Adapter SK-9843 SX
      PrefPort:A  RlmtMode:Check Link State

Mike Stone
