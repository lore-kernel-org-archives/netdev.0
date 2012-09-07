From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH RFC net-next 0/2] Take care of xfrm policy when checking dst entries
Date: Fri,  7 Sep 2012 17:57:45 +0200
Message-ID: <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5049FAE3.2050403@6wind.com>
Cc: sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vyasevich@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34139 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266Ab2IGNzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 09:55:54 -0400
In-Reply-To: <5049FAE3.2050403@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of these patches is to fix the following problem: a session is
established (TCP, SCTP) and after a new policy is inserted. The current
code does not recalculate the route, thus the traffic is not encrypted.

The patch propose to check flow_cache_genid value when checking a dst
entry, which is incremented each time a policy is inserted or deleted.

Patches are tested with TCP and SCTP.

Comments are welcome.

Regards,
Nicolas
