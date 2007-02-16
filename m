From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Sk-drivers] sky2 bonding problem, 802.3ad
Date: Fri, 16 Feb 2007 12:34:10 -0800
Message-ID: <200702162034.l1GKYA22019289@death.nxdomain.ibm.com>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de> <200702152013.l1FKDE22017473@death.nxdomain.ibm.com> <877iuitqcw.fsf@kruemel.my-eitzenberger.de> <873b56tprm.fsf@kruemel.my-eitzenberger.de>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Holger Eitzenberger <holger@my-eitzenberger.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:51304 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946138AbXBPUeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Feb 2007 15:34:15 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l1GKXb4G028711
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 15:33:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1GKYE0w538192
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 13:34:14 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1GKYD9U019031
	for <netdev@vger.kernel.org>; Fri, 16 Feb 2007 13:34:14 -0700
In-reply-to: <873b56tprm.fsf@kruemel.my-eitzenberger.de> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger <holger@my-eitzenberger.de> wrote:

>Holger Eitzenberger <holger@my-eitzenberger.de> writes:
>
>>  bonding: ad_tx_machine() 1210: Sent LACPDU on port 1
>>  bonding: bond_3ad_rx_indication() 2175: Received LACPDU on port 1
>>  bonding: ad_rx_machine() 1123: Rx Machine: Port=1, Last State=6, Curr
>>    State=6
>
>One important point I forgot about in my previous post: the host
>receives LACPDUs, but still the bond does not work.
>
>Also note that the other e1000 bond works happily: it is in fact the
>link which I use to configure it currently (via telnet).

	Can you send me (off list, I'm thinking) the full bonding debug
dmesg log as well as a tcpdump trace of the LACP exchange (i.e., the
case that LACPDUs are both sent and received)?  The raw tcpdump
("tcpdump -w somefile") is better than the formatted text output.

	I don't have either of the pieces of hardware you're using (the
switch or the sky2 card), so I'm hoping there will be some gleaming
nuggets of evidence in the logs.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
