From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH v6 ethtool 0/2] patchset - Support for configurable RSS hash key
Date: Fri, 6 Jun 2014 21:21:26 +0530
Message-ID: <1f23ef3b-5ffd-4668-aff6-a719dc63fb28@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14157 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbaFFPxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 11:53:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC drivers that support RSS use either a hard-coded value or a random value
for the RSS hash key. Irrespective of the type of the key used, the user
would want to change the hash key if he/she is not satisfied with the
effectiveness of the default hash-key in spreading the incoming flows evenly
across the RSS queues.

This patch set adds support for configuring the RSS hash-key via the ethtool
interface using .X/-x option.

v6:
1. Addressed Ben's comments.
2. Fixed memory leaks in do_grxfhindir, do_srxfhindir, do_srxfh, do_grxfh.
3. Handled memory allocation failures in do_grxfhindir, do_srxfhindir, do_srxfh, do_grxfh.

Venkat Duvvuru (2):
  ethtool: Support for configurable RSS hash key
  ethtool: Support for configurable RSS hash key

 ethtool-copy.h |  478 ++++++++++++++++++++++++++++++++++++++++++--------------
 ethtool.8.in   |   18 ++-
 ethtool.c      |  390 ++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 703 insertions(+), 183 deletions(-)
