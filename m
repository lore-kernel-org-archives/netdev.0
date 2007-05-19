From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited
 Slow-Start)
Date: Sat, 19 May 2007 10:01:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705190954040.23269@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi>
 <464DE584.7030008@ev-en.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-550050962-1179558071=:23269"
Cc: Netdev <netdev@vger.kernel.org>
To: Baruch Even <baruch@ev-en.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45246 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbXESHBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 03:01:15 -0400
In-Reply-To: <464DE584.7030008@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-550050962-1179558071=:23269
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 18 May 2007, Baruch Even wrote:

> I'm not a native English speaker but "at most" sounds a bit awkward to
> me, maybe change it to "by no more than". But I'm sure someone can find
> a better phrasing.

Neither am I, but since nothing else seems to have came up, here is one 
with your proposal... In addition to your changes, I fixed the 
capitalization of the first sentence (which was a result of copy-paste 
from RFC's title).

[PATCH] [TCP] Sysctl: Document tcp_max_ssthresh (Limited Slow-Start)

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ce16e6a..b4d0a66 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -239,6 +239,19 @@ tcp_max_orphans - INTEGER
 	more aggressively. Let me to remind again: each orphan eats
 	up to ~64K of unswappable memory.
 
+tcp_max_ssthresh - INTEGER
+	Limited Slow-Start for TCP with large congestion windows defined in
+	RFC3742. Limited slow-start is a mechanism to limit growth of the
+	congestion window on the region where congestion window is larger than
+	tcp_max_ssthresh. A TCP connection with a large congestion window could
+	have its congestion window increased by thousand (or even more)
+	segments per RTT by the traditional slow-start procedure which might be
+	counter-productive to TCP performance when packet losses start to
+	occur. With limited slow-start TCP increments congestion window by no
+	more than tcp_max_ssthresh/2 segments per RTT when the congestion
+	window is above tcp_max_ssthresh.
+	Default: 0 (off)
+
 tcp_max_syn_backlog - INTEGER
 	Maximal number of remembered connection requests, which are
 	still did not receive an acknowledgment from connecting client.
-- 
1.5.0.6

---696243703-550050962-1179558071=:23269--
