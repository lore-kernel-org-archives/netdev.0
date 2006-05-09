From: Johannes Berg <johannes@sipsolutions.net>
Subject: r8169: only works in 10mbit/half duplex
Date: Tue, 09 May 2006 03:12:24 +0200
Message-ID: <1147137144.16487.61.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60116 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751330AbWEIBMq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 21:12:46 -0400
To: romieu@fr.zoreil.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

New system, new trouble -- I got a system with a r8169 integrated (AOpen
MiniPC) and this card only works if I force it to 10mbit half duplex by
using media=1 while loading it.

Even ethtool appears to have no effect, and under windows the device
also is only used in 10mbit mode (only installed that to find out!).

At 100mbit, sending works (I can see the dhcp packets for example) but
receiving doesn't, and the tx/rx led blinks frantically when I enable it
(via auto negotiation or manually). Haven't tried gbit yet.

I'm thinking this is a hardware failure, is there any reason to believe
otherwise?

Thanks,
johannes

