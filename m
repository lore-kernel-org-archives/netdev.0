From: David Miller <davem@davemloft.net>
Subject: tree plans...
Date: Fri, 02 Mar 2007 15:57:50 -0800 (PST)
Message-ID: <20070302.155750.39156684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992777AbXCBX5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 18:57:51 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E8DEDAE54BC
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2007 15:57:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I plan to cut a net-2.6.22 tree after I finish pushing the
current round of 2.6.21 networking bug fixes to Linus.

I'll load the tcp-2.6 tree changes into net-2.6.22, and then
we'll do all non-bug-fix development in the net-2.6.22 tree.

It may take some time for me to push out the bug fixes for today
because due to the VLAN group allocation fix, I need to do an
exhaustive build test with allmodconfig and stuff like that to
make sure no drivers got accidently build broken by that change.

Thanks!
