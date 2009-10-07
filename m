From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] bridge: Allow enable/disable UFO on bridge device via
 ethtool
Date: Wed, 07 Oct 2009 15:41:17 -0700
Message-ID: <1254955277.31575.208.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:60714 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbZJGWmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 18:42:00 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n97MeJMY032699
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:40:19 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n97MfIoY181486
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:41:18 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n97MfITQ019434
	for <netdev@vger.kernel.org>; Wed, 7 Oct 2009 16:41:18 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow enable/disable UFO on bridge device via ethtool

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 07a0777..1a99c4e 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -157,6 +157,7 @@ static const struct ethtool_ops br_ethtool_ops = {
 	.get_tso	= ethtool_op_get_tso,
 	.set_tso	= br_set_tso,
 	.get_ufo	= ethtool_op_get_ufo,
+	.set_ufo	= ethtool_op_set_ufo,
 	.get_flags	= ethtool_op_get_flags,
 };
 


