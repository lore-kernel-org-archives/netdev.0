From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 0/10] ieee802154: support rf212 and extended mac features
Date: Wed, 12 Feb 2014 17:37:04 +0100
Message-ID: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:46802 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbaBLQhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:37:36 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s1CGbSZc030776
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 17:37:29 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patch set adds support for the RF212 radio chip to the existing at86rf230
driver and adds support for numerous features of the RF212 chips to the
ieee802154 stack. These features include CSMA parameter configuration, transmit
power control, CCA parameter configuration, and automatic retransmission of
frames. Netlink APIs are provided for all new options introduced in this set.

Many features might also work for RF230, but since I have no such chips at my
disposal, most new features are implemented only for RF212.
