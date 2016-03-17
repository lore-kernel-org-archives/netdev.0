From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 ethtool 0/2] IPv6 RXNFC
Date: Thu, 17 Mar 2016 19:09:10 +0000
Message-ID: <56EB00D6.3060003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:65073 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751770AbcCQTJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 15:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for steering of IPv6 receive flows.

Changes since v1:
* Fixed and simplified IPv6 address and mask parsing
* Made help text / man page more consistent
* Dropped ethtool-copy.h patch as upstream is now newer

Edward Cree (2):
  Add IPv6 support to NFC
  Documentation for IPv6 NFC

 ethtool.8.in |  29 +++++--
 ethtool.c    |  25 +++++-
 rxclass.c    | 268 +++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 298 insertions(+), 24 deletions(-)
