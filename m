From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next v2 0/2] sfc: Bowdlerise PTP MCDI errors
Date: Tue, 12 May 2015 13:03:27 +0100
Message-ID: <5551EC0F.2080607@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:57163 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932339AbbELMDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:03:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the NIC doesn't support PTP, probe-time MCDI commands fail in
predictable ways.  Instead of logging cryptic MCDI errors, just log that
PTP isn't supported.

v2: Hopefully stop Thunderbird mangling the patches.

Edward Cree (2):
  sfc: nicer log message on PTP probe fail
  sfc: suppress some MCDI error messages in PTP

 drivers/net/ethernet/sfc/ptp.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)
