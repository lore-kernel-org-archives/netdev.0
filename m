From: David Miller <davem@davemloft.net>
Subject: 2.6.24 very strict patch acceptance mode...
Date: Tue, 13 Nov 2007 20:02:53 -0800 (PST)
Message-ID: <20071113.200253.215607846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60840
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750759AbXKNECy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:02:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 27150C8C709
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2007 20:02:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Starting now I am going to be very strict about patches
for 2.6.24

This means:

1) No cleanups
2) No symbol report removals
3) No bug fixes with cleanups attached
4) No code refactoring
5) No code consolidation
6) No whitespace removals

And I really mean it.

It has to fix a bug and it has to do so without requiring
cleanups or other unrelated changes.

Thanks.
