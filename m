From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 ALB bonding printk()s every arp
Date: Tue, 14 Apr 2009 16:43:40 -0700 (PDT)
Message-ID: <20090414.164340.06293708.davem@davemloft.net>
References: <1225849876-8930-2-git-send-email-fubar@us.ibm.com>
	<1225849876-8930-3-git-send-email-fubar@us.ibm.com>
	<49E518F8.3030109@siriusit.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: duncan.gibb@siriusit.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbZDNXns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 19:43:48 -0400
In-Reply-To: <49E518F8.3030109@siriusit.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duncan Gibb <duncan.gibb@siriusit.co.uk>
Date: Wed, 15 Apr 2009 00:15:04 +0100

> On 05 Nov 2008 at 01:51, Jay Vosburgh wrote:
>>  	if (arp->op_code == htons(ARPOP_REPLY)) {
>>  		/* update rx hash table for this ARP */
>> +		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
>> +		       bond_dev->name);
>> +		bond = bond_dev->priv;
>>  		rlb_update_entry_from_arp(bond, arp);
>>  		dprintk("Server received an ARP Reply from client\n");
>>  	}
> 
> Is the printk() in this patch necessary?
> 
> We recently put a 2.6.29 kernel on a router with multiple ALB bonds each
> of several e1000 devices.  It now generates a log entry every time an
> arp is-at packet arrives at a bonded interface.  I'm not sure that's a
> feature...

That's pretty annoying.  Jay can we just remove this?
