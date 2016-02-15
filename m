From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH ethtool 0/3] IPv6 RXNFC
Date: Mon, 15 Feb 2016 14:56:58 +0000
Message-ID: <56C1E73A.5090603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:46655 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753323AbcBOO5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 09:57:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for steering of IPv6 receive flows.

Edward Cree (3):
  ethtool-copy.h: sync with net-next
  Add IPv6 support to NFC
  Documentation for IPv6 NFC

 ethtool-copy.h | 149 +++++++++++++++++++++++++++++--
 ethtool.8.in   |  34 ++++++--
 ethtool.c      |  25 +++++-
 rxclass.c      | 272 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 449 insertions(+), 31 deletions(-)
