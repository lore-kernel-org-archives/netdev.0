From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2]: UDP-Lite support in Linux 2.6.20
Date: Tue, 14 Nov 2006 08:48:39 +0000
Message-ID: <200611140848.39535@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:17573 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S933280AbWKNItI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 03:49:08 -0500
Content-Disposition: inline
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

please find attached, in two subsequent emails,
the following two patches:

Patch 1/2: UDP-Lite support for IPv4/IPv6 with
           consolidated code for UDP and UDP-Lite
           processing.

This is the modified UDP-Lite patch, exactly in the requested 
format: UDP and UDP-Lite now use separate object files and rely
on net/ipv{4,6}/udp_impl.h to resolve declaration dependencies. 

There is no other change apart from this one, i.e. it is still
the same as I have been posting for RFC earlier.
I would like to see this in 2.6.20.

Patch 2/2: This is an optional optimization intended to make
           room by inlining functions into udp_impl.h. I thought
           that this would be useful (in particular with regard 
           to the sockopt functions), as it reduces code size
           somewhat.

I have tested both patches on different architectures and with
different configurations (IPV6 = {n|m|y}).

Many thanks,
Gerrit
