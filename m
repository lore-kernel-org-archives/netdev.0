From: David Miller <davem@davemloft.net>
Subject: [GIT]: multique TX mergable set...
Date: Tue, 08 Jul 2008 02:12:48 -0700 (PDT)
Message-ID: <20080708.021248.28202057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751337AbYGHJMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 05:12:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id EDAC8C8D0A2
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 02:12:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, what I've done is take patches 2 to 22 from the multiqueue patch
set I posted last week and applied the feedback I've received so far
as appropriate.

You can find it in a GIT tree here:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-davem-2.6.git

It's based upon a clone of current net-next-2.6

I've picked these specific patches because they just move
datastructure bits around and have no functional or behavior change
whatsoever.  It's just infrastructure building that allows the real
changes to be made.

I think it would be safe to stuff these bits into net-next-2.6 right
now and it would simplify the fleshing out of the rest of the TX
multiqueue work at least for me ;-)

Unless I hear a major objection I'll toss those bits into net-next-2.6
late tomorrow.

Thanks!
