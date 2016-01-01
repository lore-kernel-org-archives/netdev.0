From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/3] net-gianfar: Fine-tuning for
 gfar_ethflow_to_filer_table()
Date: Fri, 1 Jan 2016 13:18:07 +0100
Message-ID: <56866E7F.8080609@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:52866 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbcAAMS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jan 2016 07:18:27 -0500
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 13:15:34 +0100

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (3):
  Less function calls after error detection
  Delete unnecessary variable initialisations
  Extend an initialisation clause of a for loop

 drivers/net/ethernet/freescale/gianfar_ethtool.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

-- 
2.6.3
