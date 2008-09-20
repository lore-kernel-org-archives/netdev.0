From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 00/15]: TCP rexmit changes
Date: Sat, 20 Sep 2008 20:52:18 +0300
Message-ID: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59235 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbYITRwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner noted ages ago that TCP does O(n^2) processing
during recovery. I solved SACKtag part earlier, making
duplicate ACKs to mostly avoid scanning the write queue
unnecessarily. This changeset is intented to (mostly) solve
the periods when cumulative ACKs occur during a recovery,
ie., basically when the loss situation starts to resolve.

--
 i.


