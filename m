From: David Miller <davem@davemloft.net>
Subject: 2.6.30-rc8 and net state...
Date: Tue, 02 Jun 2009 21:53:09 -0700 (PDT)
Message-ID: <20090602.215309.260215486.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56000
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332AbZFCExI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 00:53:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 86A90C8C1B4
	for <netdev@vger.kernel.org>; Tue,  2 Jun 2009 21:53:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With 2.6.30-rc8 just going out, and probably being the very
last RC with a final 2.6.30 release anticipated this weekend
I really do not expect to add anything to net-2.6 at this
point.

Don't even think about suggesting a change goes into net-2.6,
really, we're that frozen :-)

There are ~35 patches in the patchwork queue for networking,
most of which were posted today, so I should be able to merge
the vast majority of those quickly.

My personal play is to make some more attempts at moving sk_buff
over to using struct list_head, but if that isn't completed in
time for the 2.6.31 merge window it won't be the end of the world
I suppose.
