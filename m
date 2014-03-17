From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v4 ethtool 0/2] patchset - Support for configurable RSS hash key
Date: Mon, 17 Mar 2014 18:02:50 +0530
Message-ID: <39597853-033d-4a1e-a311-e40e5c0eddb9@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28293 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933022AbaCQMdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:33:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user
would want to change the hash key if he/she is not satisfied with the
effectiveness of the default hash-key in spreading the incoming flows evenly
across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using .X/-x option.

v4:
1. Edited ethtool_rxfh command description to fit into one physical line.
2. Edited rss_config description to explain how indirection table and hashkey
   are arranged in memory.
3. Added description about what "indir_size == 0xDEADBEEF" means.


Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 ethtool-copy.h |   34 +++++++-
 ethtool.8.in   |   18 +++--
 ethtool.c      |  253 ++++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 244 insertions(+), 61 deletions(-)
