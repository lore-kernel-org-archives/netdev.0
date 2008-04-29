From: Dave Jones <davej@redhat.com>
Subject: odd RTL8139 quirk.
Date: Tue, 29 Apr 2008 13:14:03 -0400
Message-ID: <20080429171403.GA21035@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755906AbYD2ROF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 13:14:05 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3THE4Ck004364
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 13:14:04 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m3THE4Ok016985
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 13:14:04 -0400
Received: from quoit.install.boston.redhat.com (quoit.install.boston.redhat.com [10.13.0.212])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m3THE4BK024060
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 13:14:04 -0400
Received: from quoit.install.boston.redhat.com (localhost.localdomain [127.0.0.1])
	by quoit.install.boston.redhat.com (8.14.2/8.14.1) with ESMTP id m3THE3nD008460
	for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 13:14:03 -0400
Received: (from davej@localhost)
	by quoit.install.boston.redhat.com (8.14.2/8.14.2/Submit) id m3THE3H6008459
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 13:14:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just been playing with a model 2 OQO, which has an RTL8139.
It gets detected just fine, though it doesn't actually work..

eth0: RealTek RTL8139 at 0xf8830000, 00:00:00:00:00:00, IRQ 18
eth0:  Identified 8139 chip type 'RTL-8139'

The null MAC address being one clue.  Another oddity is that
ethtool reports that there's no link detected, even though there is.
(Enough for it to PXE boot a kernel from at least :)

Futzing with the debug= modparam didn't yield anything extra at all.

Any clues?

	Dave

-- 
http://www.codemonkey.org.uk
