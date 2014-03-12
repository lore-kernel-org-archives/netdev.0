From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v3 5/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Wed, 12 Mar 2014 15:26:37 -0700
Message-ID: <1394663197.3915.61.camel@joe-AO722>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
	 <1394577791-6547-6-git-send-email-vbridgers2013@gmail.com>
	 <1394578747.28839.4.camel@joe-AO722>
	 <CAOwfj2Ot+ssTZgMoOoShVEUi+RkxjpPpRUfHAkP9RETm3TuUzg@mail.gmail.com>
	 <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0058.hostedemail.com ([216.40.44.58]:39697 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751101AbaCLW0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 18:26:41 -0400
In-Reply-To: <1394658856.20857.7.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-12 at 21:14 +0000, Ben Hutchings wrote:
> These look like the statistic names specified in IEEE 802.3.  I would
> support a general move to using standard names for MAC stats in Ethernet
> drivers, because they are quite clearly defined and widely implemented
> in hardware.  However, that is not the current practice in most Linux
> drivers.

Hey Ben.

Maybe something like this would be a start?

Change the actual #defines/strings to taste.

Maybe this shouldn't be in uapi or maybe in if_ether.h

---
 include/uapi/linux/ethtool.h | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index fd161e9..24b8b51 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -498,6 +498,36 @@ struct ethtool_pauseparam {
 
 #define ETH_GSTRING_LEN		32
 
+#define ETH_GSTRING_RX_PKTS		"rx_packets"
+#define ETH_GSTRING_RX_BYTES		"rx_bytes"
+#define ETH_GSTRING_RX_TOTAL_BYTES	"rx_total_bytes"
+#define ETH_GSTRING_RX_TOTAL_PKTS	"rx_total_packets"
+#define ETH_GSTRING_RX_CRC_ERRS		"rx_crc_errors"
+#define ETH_GSTRING_RX_ALIGN_ERRS	"rx_align_errors"
+#define ETH_GSTRING_RX_PAUSE		"rx_pause"
+#define ETH_GSTRING_RX_ERRS		"rx_errors"
+#define ETH_GSTRING_RX_UNICAST		"rx_unicast"
+#define ETH_GSTRING_RX_MULTICAST	"rx_multicast"
+#define ETH_GSTRING_RX_BROADCAST	"rx_broadcast"
+#define ETH_GSTRING_RX_FIFO_DROPS	"rx_fifo_drops"
+#define ETH_GSTRING_RX_UNDERSIZE	"rx_undersize"
+#define ETH_GSTRING_RX_OVERSIZE		"rx_oversize"
+#define ETH_GSTRING_RX_DUPLICATES	"rx_duplicates"
+#define ETH_GSTRING_RX_DROPPED		"rx_dropped"
+#define ETH_GSTRING_RX_FRAGMENTS	"rx_fragments"
+
+#define ETH_GSTRING_TX_PKTS		"tx_packets"
+#define ETH_GSTRING_TX_BYTES		"tx_bytes"
+#define ETH_GSTRING_TX_TOTAL_BYTES	"tx_total_bytes"
+#define ETH_GSTRING_TX_TOTAL_PKTS	"tx_total_packets"
+#define ETH_GSTRING_TX_PAUSE		"tx_pause"
+#define ETH_GSTRING_TX_ERRS		"tx_errors"
+#define ETH_GSTRING_TX_DISCARDS		"tx_discards"
+#define ETH_GSTRING_TX_UNICAST		"tx_unicast"
+#define ETH_GSTRING_TX_MULTICAST	"tx_multicast"
+#define ETH_GSTRING_TX_BROADCAST	"tx_broadcast"
+#define ETH_GSTRING_TX_DROPPED		"tx_dropped"
+
 /**
  * enum ethtool_stringset - string set ID
  * @ETH_SS_TEST: Self-test result names, for use with %ETHTOOL_TEST
