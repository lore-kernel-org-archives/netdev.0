From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 0/2] clsact frontend
Date: Tue, 12 Jan 2016 01:42:18 +0100
Message-ID: <cover.1452558352.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59854 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760074AbcALAmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 19:42:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup on ingress and addition of clsact frontend. There's no man-page
for ingress nor for clsact, will follow-up with one to document both.

The patch requires a header update and is against your current net-next
branch (pre master merge).

Thanks!

Daniel Borkmann (2):
  tc, ingress: clean up ingress handling a bit
  tc, clsact: add clsact frontend

 tc/Makefile    |  1 +
 tc/q_clsact.c  | 34 ++++++++++++++++++++++++++++++++++
 tc/q_ingress.c | 20 +++++---------------
 tc/tc_filter.c | 46 ++++++++++++++++++++++++++++++++++++++--------
 tc/tc_qdisc.c  | 32 ++++++++++++++++++--------------
 5 files changed, 96 insertions(+), 37 deletions(-)
 create mode 100644 tc/q_clsact.c

-- 
1.9.3
