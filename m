From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bug in arp handling 2.6.20
Date: Thu, 06 Sep 2007 18:16:51 -0700
Message-ID: <46E0A683.4030902@hp.com>
References: <50155211-787D-48AE-B9D8-7FD18406C8E3@ontoserve.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joseph Southwell <joseph@ontoserve.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:48648 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbXIGBRX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 21:17:23 -0400
In-Reply-To: <50155211-787D-48AE-B9D8-7FD18406C8E3@ontoserve.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Southwell wrote:
> scenario
> Machine A
> eth0 is plugged  into network.
> 192.168.1.201
> eth0:1
> 192.168.1.2
> 
> 
> Machine B
> eth1 is plugged into network.
> 192.168.1.101
> eth0 is not plugged into network. so I can test locally before  
> switching the wire.
> 192.168.1.201
> eth0:1
> 192.168.1.2
> 
> arp request for 192.168.1.2 is responded to by eth1 on machine B.  That 
> seems buggy to me. 

Does it still do so if you set either "arp_ignore" or "arp_filter" (I 
can never keep those two straight)?  Could be the "weak-end-system" 
design of the stack at work here.  That allows any interface in the 
system to respond to an ARP request for any of the IP's assigned to any 
of the interfaces.

> worse, it continues to do it after  unconfiguring 
> eth0:1 and eth0.

As in simply marking it "down?"

rick jones
