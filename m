From: Ben Hutchings <bhutchings@solarflare.com>
Subject: TCP sequence number security fixes for stable
Date: Tue, 8 Jan 2013 17:13:27 +0000
Message-ID: <1357665207.2750.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	John Dykstra <john.dykstra1@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63836 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428Ab3AHRNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 12:13:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please consider these for your stable update queue:

282f23c6ee343 tcp: implement RFC 5961 3.2
0c24604b68fc7 tcp: implement RFC 5961 4.2
e371589917011 tcp: refine SYN handling in tcp_validate_incoming
bd090dfc634dd tcp: tcp_replace_ts_recent() should not be called from tcp_validate_incoming()
354e4aa391ed5 tcp: RFC 5961 5.2 Blind Data Injection Attack Mitigation

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
