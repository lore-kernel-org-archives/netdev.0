From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Subject: TX_RING and VLAN : (packet size is too long 1518 > 1514)
Date: Sun, 23 Feb 2014 12:03:54 +0100
Message-ID: <5309D59A.1020304@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jbrouer@redhat.com>, <netdev@vger.kernel.org>
To: <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-gate10-dus.antispameurope.com ([94.100.134.110]:38562 "EHLO
	mx-relay10-dus.antispameurope.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750867AbaBWLEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 06:04:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel, all

we're running into the above error when sending full-sized VLAN-tagged 
frames via TX_RING (Kernel 3.10.31, but same code seems to be present in 
3.14).

For the regular send() calls, there seems to be code in place to handle 
VLAN-tagged frames, but in tpacket_fill_skb() there is no such check.

I came up with fix for this, but can only verify this tomorrow.
If it works, I'd send you a patch, but someone with more insights into 
the networking code should probably fix this properly ;-)

Cheers,

Mathias
