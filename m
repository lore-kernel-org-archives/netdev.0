From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][patch 0/2] Dynamically allocate the loopback
Date: Mon, 17 Sep 2007 15:45:09 +0200
Message-ID: <20070917134509.222896190@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:4915 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850AbXIQNxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 09:53:42 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8HDreh4204558
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 13:53:40 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HDrdqi1994972
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 15:53:40 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HDrdTZ028290
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 15:53:40 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows to dynamically allocate the loopback
like an usual network device.

This global static variable loopback_dev has been replaced by a
netdev pointer and the init function does the usual allocation,
initialization and registering of the loopback.

This patchset is splitted in two parts, the first one is a big but
trivial patch which replace the usage of the static variable loopback_dev
by the usage of a pointer. The second patch is the interesting part where
the loopback is dynamically allocated.

-- 
