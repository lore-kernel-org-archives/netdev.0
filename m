From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/8] inetpeer for ipv6, take 2
Date: Tue, 30 Nov 2010 13:21:52 -0800 (PST)
Message-ID: <20101130.132152.260110265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085Ab0K3VV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 16:21:27 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DD66524C088
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 13:21:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ok, this time, thanks to feedback from Eric Dumazet and others,
I've taken a more systematic approach to these changes.

Now there are two seperate AVL trees for ipv4 and ipv6.

Looking further, I've considered a dumping facility for these
things as currently there is no real way to monitor these
tables and we surely will want to if inetpeer takes on more
responsibilities.
