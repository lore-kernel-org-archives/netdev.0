From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Cannot receive multicast packets
Date: Thu, 20 Apr 2006 17:15:02 -0700
Message-ID: <OF10DE8AFB.1FB28740-ON88257156.0083D32C-88257157.0000E5BE@us.ibm.com>
References: <4447DFDD.8010008@cloakmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:59780 "EHLO
	e34.co.us.ibm.com") by vger.kernel.org with ESMTP id S932159AbWDUALT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:11:19 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3L09pqS010280
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:09:51 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3L06AJi091586
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 18:06:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3L09pEN026312
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 18:09:51 -0600
In-Reply-To: <4447DFDD.8010008@cloakmail.com>
To: Andrew Athan <aathan_linux_net_1542@cloakmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've run your test program and it receives fine for me.

I note that the source address is not on the same subnet as
(any of) the receiver's addresses. Are the packets being
routed? The default multicasting TTL is 1, though I don't
know if it'll be checked or dropped on the receiver, seeing
as we aren't forwarding it.

Also, you might want to run "netstat -s" to see if any of the
drop counters are being incremented (e.g., checksum error).

Finally, I'm assuming you don't have any firewall rules that
are matching, right?

                                        +-DLS

