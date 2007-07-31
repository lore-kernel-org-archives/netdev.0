From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: on [ab]use of skb->cb by VLAN code
Date: Tue, 31 Jul 2007 09:56:39 -0700
Message-ID: <46AF69C7.1090504@hp.com>
References: <1185847324.5162.31.camel@localhost>	<20070730.190621.13770511.davem@davemloft.net>	<46AEBADB.7030007@candelatech.com>	<20070730.221847.74747100.davem@davemloft.net> <46AEC99E.10809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	kaber@trash.net, netdev@vger.kernel.org, mcarlson@broadcom.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:58111 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765646AbXGaQ5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 12:57:32 -0400
In-Reply-To: <46AEC99E.10809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Do we really need an 'unsigned int' for mac_len?  Maybe we could use
> a 16-bit counter here, and then use the other 16 bits for the VLAN bits?

Not knowing exactly if/how it interacts with that specific field I will 
point-out that IPoIB in OFED 1.2 just took their MTU to 65520.  While that 
doesn't break the bitbank it does get rather close.

rick jones
