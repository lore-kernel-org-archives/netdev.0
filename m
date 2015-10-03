From: Andreas Schwab <schwab@linux-m68k.org>
Subject: 4.3-rc3: `telnet ::1 <port>' hangs in SYN-SENT
Date: Sat, 03 Oct 2015 21:39:25 +0200
Message-ID: <87oagf4u8i.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50456 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbJCTjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 15:39:31 -0400
Received: from frontend01.mail.m-online.net (unknown [192.168.8.182])
	by mail-out.m-online.net (Postfix) with ESMTP id 3nSz694VTcz3hj6q
	for <netdev@vger.kernel.org>; Sat,  3 Oct 2015 21:39:26 +0200 (CEST)
Received: from localhost (dynscan1.mnet-online.de [192.168.6.68])
	by mail.m-online.net (Postfix) with ESMTP id 3nSz666MlszvhLP
	for <netdev@vger.kernel.org>; Sat,  3 Oct 2015 21:39:26 +0200 (CEST)
Received: from mail.mnet-online.de ([192.168.8.182])
	by localhost (dynscan1.mail.m-online.net [192.168.6.68]) (amavisd-new, port 10024)
	with ESMTP id MQgEfnFG7dkc for <netdev@vger.kernel.org>;
	Sat,  3 Oct 2015 21:39:26 +0200 (CEST)
Received: from igel.home (ppp-93-104-63-53.dynamic.mnet-online.de [93.104.63.53])
	by mail.mnet-online.de (Postfix) with ESMTPA
	for <netdev@vger.kernel.org>; Sat,  3 Oct 2015 21:39:26 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trying to connect to ::1 on any port (whether or not anything listens)
causes the connection to hang in SYN-SENT state.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
