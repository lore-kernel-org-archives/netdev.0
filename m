From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 0/6] enic: updates to version 1.1.0.241
Date: Fri, 18 Dec 2009 18:09:36 -0800
Message-ID: <20091219020758.2745.85264.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:17430 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755960AbZLSCJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 21:09:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements enic driver updates:

1/6 - Bug fix: use safe queue shutdown in dev->stop
2/6 - Bug fix: try harder to fill Rx ring on skb allocation failures
3/6 - minimize pkt filter updates to firmware
4/6 - Bug fix: align desc ring sizes to 32 descs
5/6 - feature add: add ethtool -c/C support
6/6 - whitespace cleanup; #define cleanup; more verbose err msg

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
