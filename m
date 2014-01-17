From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: [PATCH 0/4] Patchset - Support for configurable RSS hash key
Date: Fri, 17 Jan 2014 13:02:10 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:56770 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbaAQNCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 08:02:11 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value for the RSS hash key. Irrespective of the type of the key used, the user would want to change the hash key if he/she is not satisfied with the effectiveness of the default hash-key in spreading the incoming flows evenly across the RSS queues.

This patch set provides support for configuring the RSS hash-key via the ethtool interface.

The patch set consists of:
a) ethtool user-land patches
b) ethtool kernel patch
c) be2net patch that implements the ethtool hooks
