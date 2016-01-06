From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/2] net: break dependency of drivers on geneve and vxlan
Date: Wed,  6 Jan 2016 16:41:41 +0100
Message-ID: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:60769 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751330AbcAFPlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 10:41:50 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A5A7E20B0D
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 10:41:49 -0500 (EST)
Received: from z.localhost.localdomain (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 213A2C013FE
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 10:41:49 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device drivers which support geneve or vxlan offloading have a dependency
on the correlating kernel modules. Thus those drivers automatically loaded
the geneve or vxlan modules. Break this dependency with this small series.

Hannes Frederic Sowa (2):
  vxlan: break dependency to network drivers
  geneve: break dependency to network drivers

 drivers/net/geneve.c      | 30 +++++++++++++++++++++++++++---
 drivers/net/vxlan.c       | 17 +++++++++++------
 include/linux/netdevice.h |  2 ++
 include/net/geneve.h      |  7 +++----
 include/net/vxlan.h       |  5 +----
 5 files changed, 44 insertions(+), 17 deletions(-)

-- 
2.5.0
