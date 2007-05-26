From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 0/9]: tcp-2.6 patchset
Date: Sat, 26 May 2007 11:35:53 +0300
Message-ID: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47757 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbXEZIgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here are some changes to TCP I've been baking. Before doing this
patchset, I rebased tcp-2.6 branch to the current net-2.6 (goes
almost cleanly) because there are some depencies to the TCP work in
there.

I booted these today and no very obvious problems showed up (OOPSes,
BUG()s, reported scoreboard leaks, etc.) while I did some transfers
with varying sysctl settings: SACK/FACK on/off and FRTO enabled).
However, no in depth analysis on behavior has been made.

The last patch is highly experimental (and incomplete), it should
NOT be applied yet. I suspect that there are at least off-by-MSS
things in it.

I'm asking for your comments.


Dave, you could consider applying other than the last one if they
seem ok to you too (you'll need to rebase your tcp-2.6 in that case
first to apply cleanly those that touch tcp_sync_left_out :-)).

-- 
 i.

