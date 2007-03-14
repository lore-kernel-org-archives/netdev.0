From: David Miller <davem@davemloft.net>
Subject: [GIT]: Multipath cached, just say no
Date: Wed, 14 Mar 2007 15:40:13 -0700 (PDT)
Message-ID: <20070314.154013.63126053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46196
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752844AbXCNWkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 18:40:15 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3476F110098
	for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 15:40:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


For those of you who want to be the first on your block
to be running a kernel without any of that icky multipath
cached code in your tree, I've created a tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/mpkill-2.6.git

Everything and anything referring to the multipath cache bits
(besides some ARM platform defconfigs) has been removed in that
tree, it's a clone of Linus's current GIT plus the removals.

Cleanups et al. against this (and there are probably many possible
at this early stage) are very welcome.

We'll push this into 2.6.23, and I promise to fight hard for it this
time unlike the past 4 or 5 times I've tried to pull this off before.

Help from others would be majorly appreciated when people complain on
here and linux-kernel, I can't do it alone :)

