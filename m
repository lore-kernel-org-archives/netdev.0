From: Jakub Kicinski <moorray3@wp.pl>
Subject: [PATCH 0/3] gianfar: filer changes
Date: Mon, 10 Aug 2015 22:12:17 +0200
Message-ID: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Cc: netdev@vger.kernel.org, Jakub Kicinski <kubakici@wp.pl>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:54999 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbbHJUTG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 16:19:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

Hi,

I've been working with the gianfar filer code recently and got
some code to offer.  Well, maybe not that much code to offer
actually: two small fixes and removal of the current optimizer.
I'm not sure what your feelings on patch 3 will be.  It would
be great to have a working optimizer if someone wants to take
this task up but currently we have a semi-broken one and I vote
for killing the beast entirely before it has a chance to bite
more people...

Jakub Kicinski (3):
  gianfar: correct filer table writing
  gianfar: correct list membership accounting
  gianfar: remove faulty filer optimizer

 drivers/net/ethernet/freescale/gianfar_ethtool.c | 345 +----------------------
 1 file changed, 4 insertions(+), 341 deletions(-)

-- 
2.1.0
