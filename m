From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 0/2] Fix compiler-errors with gcc 4.7.3
Date: Sat, 20 Jul 2013 21:58:16 +0200
Message-ID: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:35318 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844Ab3GTUG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 16:06:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc complains about unused return-values in ss.c and lnstat_util.c

In ss, upon the calls to fscanf, I added an empty if-statement to suppress
the compiler-error. Admittedly not a very neat solution, but we can't do
anything more here.

If you want me to handle the fscanf-case differently, let me know.


Christoph Paasch (2):
  ss: Fix compiler errors of unused return-values
  lnstat: Fix compiler errors of unused return-values

 misc/lnstat_util.c | 12 ++++++++----
 misc/ss.c          | 30 +++++++++++++++++++++---------
 2 files changed, 29 insertions(+), 13 deletions(-)

-- 
1.8.1.2
