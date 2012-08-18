From: Andreas Schwab <schwab@linux-m68k.org>
Subject: [3.6-rc1 regression] Data stuck in Send-Q?
Date: Sat, 18 Aug 2012 14:57:18 +0200
Message-ID: <m2k3ww1hox.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:37693 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709Ab2HRM5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 08:57:22 -0400
Received: from frontend1.mail.m-online.net (frontend1.mail.intern.m-online.net [192.168.8.180])
	by mail-out.m-online.net (Postfix) with ESMTP id 3WzhBm694pz3hhbG
	for <netdev@vger.kernel.org>; Sat, 18 Aug 2012 14:57:19 +0200 (CEST)
Received: from igel.home (ppp-88-217-111-114.dynamic.mnet-online.de [88.217.111.114])
	by mail.mnet-online.de (Postfix) with ESMTPA id 3WzhBl2ngkzbbjK
	for <netdev@vger.kernel.org>; Sat, 18 Aug 2012 14:57:19 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing connections stall with data being stuck in the send queue.
Apparently that only happens when the connection is about to be closed,
after the payload has been received completely.  Unfortunately this
doesn't happen reliably, so it would be a pain to bisect.  Any idea how
to track down?

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
