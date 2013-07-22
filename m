From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 v2 0/2] Fix compiler-errors with gcc 4.7.3
Date: Mon, 22 Jul 2013 19:24:15 +0200
Message-ID: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:42597 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334Ab3GVRYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 13:24:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc complains about unused return-values in ss.c and lnstat_util.c

Christoph Paasch (2):
  ss: Fix compiler errors of unused return-values
  lnstat: Fix compiler errors of unused return-values

 misc/lnstat_util.c | 12 ++++++++----
 misc/ss.c          | 33 ++++++++++++++++++++++++---------
 2 files changed, 32 insertions(+), 13 deletions(-)

-- 
1.8.1.2
