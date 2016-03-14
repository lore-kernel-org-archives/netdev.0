From: Arnd Bergmann <arnd@arndb.de>
Subject: net: gcc-6.0 warning fixes
Date: Mon, 14 Mar 2016 15:18:33 +0100
Message-ID: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:58770 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444AbcCNOSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 10:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just installed gcc-6.0 to see what kinds of new warnings
we get. It turns out that it's actually really useful once I
disabled -Wunused-const-variable, and all of the warnings it
found in network drivers seem valid.

Sorry for the bad timing in the merge window, but I figured
it would be better to send the fixes as I found the bugs
rather than waiting for the next cycle. The first three
look appropriate for stable backports.

The other two only fix a gcc warning about incorrect whitespace,
probably not worth backporting those.

        Arnd
