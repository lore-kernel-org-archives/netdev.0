From: Toerless Eckert <tte@cs.fau.de>
Subject: vnet problem (bug? feature?)
Date: Fri, 13 Feb 2015 12:41:13 +0100
Message-ID: <20150213114113.GA10559@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:37243 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751535AbbBMLlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 06:41:15 -0500
Received: from faui40p.informatik.uni-erlangen.de (faui40p.informatik.uni-erlangen.de [131.188.34.77])
	by faui40.informatik.uni-erlangen.de (Postfix) with ESMTP id 6412C5904CF
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 12:41:13 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hope this is the right mailing list, if not, then which one ? (thanks)

- Created vnet pair
- NOT putting them into different namespaces.
- Unicast across them works fine.
- When sending IP multicsast into one end, i can not receive it on the other side
  (with normal socket API applications).

Interestingly:
- When using tcpdump (pcap), i can actually see the multicast packets
  both when binding to the sending vnet interface and when binding to
  the receiving vnet.
- When using tcpdump and sending unicast, tcpdump doesn't show me any packets ;-(

When putting one vnet interface into a separate namespace, i can send
multicast packets. I wonder if what i see is not a result of namespaces
but just how multicast packets interact with the routing table(s) (single
one when both vnet interfaces are in the same namespace).

Tihis is unfortunately all with an old kernel (3.7), i'll try to get a newer
kernel on some PC, a bit constrained on available HW, so thought i dare to
ask before having tested on the latest kernel.

(btw: Is there any api to put an interface back from a namespace into default ?)

Thanks!
    Toerless
