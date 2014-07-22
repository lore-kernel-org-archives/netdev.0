From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v7 ethtool 0/2] patchset - Support for configurable RSS hash key
Date: Tue, 22 Jul 2014 17:51:05 +0530
Message-ID: <e8020e05-df87-4251-90b1-cbaf53296631@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:47595 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbaGVMYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 08:24:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user
would want to change the hash key if he/she is not satisfied with the
effectiveness of the default hash-key in spreading the incoming flows evenly
across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using -X/-x option.

v7:
1. Changed rss string to RSS to be consistent with other parts of the error codes
   and documentation.
2. Corrected a few error messages
3. Changed error codes to use either 1 or 2 based on the situation
4. Added test cases in test-cmdline.c

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key.
  ethtool: Support for configurable RSS hash key.

 ethtool-copy.h |  478 ++++++++++++++++++++++++++++++++++++++++++--------------
 ethtool.8.in   |   18 ++-
 ethtool.c      |  393 +++++++++++++++++++++++++++++++++++++++--------
 test-cmdline.c |   11 ++
 4 files changed, 717 insertions(+), 183 deletions(-)
