From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v3 ethtool 0/2] patchset: Support for configurable RSS hash key
Date: Fri, 28 Feb 2014 17:40:42 +0530
Message-ID: <ae45dac1-e9b2-48f2-acbc-3d3c3c17588a@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:52303 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaB1MKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 07:10:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user
would want to change the hash key if he/she is not satisfied with the
effectiveness of the default hash-key in spreading the incoming flows evenly
across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the
ethtool interface using -X option.

v3:
1. ETHTOOL_GRXFHINDIR, ETHTOOL_SRXFHINDIR command numbers & structure
are left unchanged.
2. Introduced new command numbers & structure for ETHTOOL_GRSSH & ETHTOOL_SRSSH.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 ethtool-copy.h |   33 +++++++-
 ethtool.8.in   |   18 +++--
 ethtool.c      |  253 ++++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 243 insertions(+), 61 deletions(-)
