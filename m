From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v5 ethtool 0/2] patchset - Support for configurable RSS hash key
Date: Mon, 21 Apr 2014 15:38:49 +0530
Message-ID: <501b590b-178c-4c69-b82b-e7cfa96276ef@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:16876 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaDUKJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 06:09:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user
would want to change the hash key if he/she is not satisfied with the
effectiveness of the default hash-key in spreading the incoming flows evenly
across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using .X/-x option.

v5:
1. Added rss_context field to ethtool_rxfh structure to support multiple
   rss contexts.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 ethtool-copy.h |   34 +++++++-
 ethtool.8.in   |   18 +++--
 ethtool.c      |  253 ++++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 244 insertions(+), 61 deletions(-)
