From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Ignoring destination MAC address in incoming packets
Date: Mon, 08 Apr 2013 09:49:35 +0200
Message-ID: <m3ppy5mpgw.fsf@intrepid.localdomain>
References: <m3txnhmrdm.fsf@intrepid.localdomain>
	<20130408071903.GB5938@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:54396 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933969Ab3DHHth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 03:49:37 -0400
In-Reply-To: <20130408071903.GB5938@ritirata.org> (Antonio Quartulli's message
	of "Mon, 8 Apr 2013 09:19:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Antonio Quartulli <ordex@autistici.org> writes:

> May be a stupid suggestion, but what about setting promisc mode on?

I use promiscuous mode, but the packets are still dropped because
skb->pkt_type = PACKET_OTHERHOST (since the destination MAC address
doesn't match and is not broadcast/multicast).

I realize accepting all packets blindly opens a can of worms and this
must be well thought. Perhaps a user space tool using AF_PACKET is a
better way?
-- 
Krzysztof Halasa
