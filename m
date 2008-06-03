From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH 0/2] HTB scheduler HTB_HYSTERESIS modifications
Date: Tue, 03 Jun 2008 16:03:23 +0200
Message-ID: <1212501803.13164.27.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Martin Devera <devik@cdi.cz>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56443 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbYFCObN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 10:31:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set modifies the HTB schedulers hysteresis mode.  The HTB
hysteresis is a hack to reduce the CPU load, it introduces significant
jitter, enough to disturbe VoIP quality on e.g. ADSL.

The first patch changes HTB_HYSTERESIS to default off.

The second patch Change HTB_HYSTERESIS to a runtime parameter
htb_hysteresis, adjustable via
sys/module/sch_htb/parameters/htb_hysteresis.

For details about my measurements see masters thesis
(http://www.adsl-optimizer.dk/thesis/), chapter 7, section 7.3.1,
page 69-70.

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
