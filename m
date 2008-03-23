From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 0/5] [IPROUTE2] Add overhead parameter for CBQ, TBF and
	police
Date: Mon, 24 Mar 2008 00:46:33 +0100
Message-ID: <1206315993.15884.56.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-server.lanfw.cxnet.dk ([87.72.215.201]:48951 "EHLO
	comxexch02.comx.local" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756673AbYCWXrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Mar 2008 19:47:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen

This can be view as a maintanance patchset for iproute2.  The overhead
parameter, introduced in kernel 2.6.24, were only implemented for HTB
in iproute2/tc.

This patchset adds overhead parameter parsing for the last rate-table
based schedulers CBQ, TFB and police.

The changes are ABI (Application Binary Interface) backward compatible
with older kernels, but will first have effect from kernel 2.6.24.


See you soon :-)
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
