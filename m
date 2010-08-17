From: Paul Rolland <rol@as2917.net>
Subject: IPv6 raw socket and recvfrom
Date: Tue, 17 Aug 2010 14:31:20 +0200
Message-ID: <20100817143120.7fad5186@tux.DEF.witbe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.witbe.net ([81.88.96.48]:57461 "EHLO smtp.witbe.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab0HQMg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 08:36:57 -0400
Received: from tux.DEF.witbe.net (host-95.DEF.witbe.net [192.168.0.95])
	by smtp.witbe.net (8.14.1/8.14.1) with ESMTP id o7HCVKX5015710
	for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 14:31:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'd like someone to clarify the behavior I can expect from a RAW IPv6
socket _in Linux_ :
 - Raw IPv4 sockets : recvfrom() payload contain all the IP header,
   including src ip, dst ip, etc...

 - Raw IPv6 sockets : so far, recvfrom returns me only the payload. I've
   added the HDRINCL options, but it seems that this is a no-op in
   IPv6-land.

I've reviewed RFC 3542, which states that I'm not to expect ip6 header, but
often "there is more than one way to do it", and I'd like to be sure I'm
not missing something obvious

Paul

PS : I'm not subscribed to netdev, so please answer directly...

