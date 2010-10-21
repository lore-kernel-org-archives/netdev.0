From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/12] benet: make be_poll_rx local
Date: Thu, 21 Oct 2010 10:50:48 -0700
Message-ID: <20101021175148.226174821@vyatta.com>
References: <20101021175045.625707607@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Sathya Perla <sathyap@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	Ajit Kha
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36304 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756371Ab0JUSBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 14:01:05 -0400
Content-Disposition: inline; filename=benet-local.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used in one file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/benet/be_main.c	2010-10-21 08:51:43.772014277 -0700
+++ b/drivers/net/benet/be_main.c	2010-10-21 08:51:59.225470145 -0700
@@ -1674,7 +1674,7 @@ static inline bool do_gro(struct be_adap
 	return (tcp_frame && !err) ? true : false;
 }
 
-int be_poll_rx(struct napi_struct *napi, int budget)
+static int be_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct be_eq_obj *rx_eq = container_of(napi, struct be_eq_obj, napi);
 	struct be_rx_obj *rxo = container_of(rx_eq, struct be_rx_obj, rx_eq);


