From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 0/6] enic: updates to version 1.1.0.241a
Date: Wed, 23 Dec 2009 15:27:25 -0800
Message-ID: <20091223232551.19428.18916.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6119 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799AbZLWX10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:27:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending with updates to address issues raised by Ben Hutchings and
Simon Horman and then Ben Hutchings again.

Please apply to net-next.

1/6 - Bug fix: use safe queue shutdown in dev->stop
2/6 - Bug fix: try harder to fill Rx ring on skb allocation failures
3/6 - minimize pkt filter updates to firmware
4/6 - Bug fix: align desc ring sizes to 32 descs
5/6 - feature add: add ethtool -c/C support
6/6 - whitespace cleanup; #define cleanup; more verbose err msg

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Scott Feldman <scofeldm@cisco.com>
