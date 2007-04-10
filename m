From: David Miller <davem@davemloft.net>
Subject: net-2.6.22 plans...
Date: Tue, 10 Apr 2007 13:57:46 -0700 (PDT)
Message-ID: <20070410.135746.106438579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030667AbXDJU5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 16:57:45 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 68299AE41FD
	for <netdev@vger.kernel.org>; Tue, 10 Apr 2007 13:57:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As the merge window approaches I've made a decision about how to
handle the TCP RB-Tree work since it's getting really close.

First, I'm going to rebase the net-2.6.22 tree after making a quick
run through my patch backlog looking for low hanging fruit.  I will
include the TCP write queue abstraction bits but not any of the
TCP RB-Tree based work.

Then I'll clone a tcp-2.6 tree from the rebased net-2.6.22 and put all
of the TCP RB-Tree bits in there.

There is not enough time to do a proper performance analysis of the
RB-Tree stuff and I'm busy working on other things at the moment so I
won't be able to do it myself soon either.  So we'll try to take care
of things in time for 2.6.23

Some minor conflicts might result from yanking out the RB-Tree bits
from net-2.6.22 so give me a day or two to finish this.

Thanks.
