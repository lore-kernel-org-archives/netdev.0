From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/42] Kill -Wunused-but-set warnings
Date: Sun, 17 Apr 2011 17:32:33 -0700 (PDT)
Message-ID: <20110417.173233.193710905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40521
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751536Ab1DRAdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:09 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B657C24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:32:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The weather is real nice, so I decided to lock myself inside and
fix compiler warnings.

I started using gcc-4.6.x on my primary sparc64 build test machine the
other week and it now enables -Wunused-but-set with -Wall and it does
catch a bunch of bogus stuff.

Most of the cases are where you'd expect them, ISDN and ATM.

This is the first pass I've made over the networking cases.

There's still a bunch more to do.
