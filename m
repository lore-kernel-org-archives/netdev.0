From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: incoming interface + ifb0
Date: Tue, 29 Jul 2008 13:22:09 +0300
Message-ID: <200807291322.10084.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:48695 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410AbYG2KWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 06:22:33 -0400
Received: from [195.69.208.252] (unknown [195.69.208.252])
	by relay2.globalproof.net (Postfix) with ESMTP id 60BD5130438
	for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 13:22:30 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry that i am asking in kernel maillist, probably it is wrong. Maybe right place is lartc only, but probably kernel lacking something too :-)

Question is:
I have plenty pppX interfaces. I want to shape traffic coming over this interfaces.
Before i was doing over m_ipt and MARK, then redirect to ifb0 and there was doing filter by fwmark.
But m_ipt seems needs serious rewrite, and plus it is not very clean way to do (performance wise).

Alternative way is to shape on outgoing interface, but it is not clean, in case if there is multiple outgoing interfaces. 
I tried to filter on ifb by ematch - rt_iif, dev - no luck. by route fromif - no luck. Is there some way i miss?
