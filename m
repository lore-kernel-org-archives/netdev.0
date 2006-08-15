From: David Miller <davem@davemloft.net>
Subject: XFRM_MSG_NEWAE
Date: Tue, 15 Aug 2006 00:28:52 -0700 (PDT)
Message-ID: <20060815.002852.35359129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6794
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965254AbWHOH2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:28:50 -0400
To: hadi@cyberus.ca
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I seem to get two of these for every key I type over an SSH session
that goes over IPSEC.

root@sunset:~/src/GIT/iproute2/ip# ./ip xfrm mon
Unknown message: 00000096 0x0000001e 0x00000000
Unknown message: 00000096 0x0000001e 0x00000000
Unknown message: 00000096 0x0000001e 0x00000000
...

Are these being emitted for every replay window update during packet
send and receive?

I think we need a way to tone this down, so that if there are no truly
interested parties we don't do the km->notify work at all.

Also it would be nice to add xfrm mon support to print out these
messages properly if you haven't coded that up already :-)
