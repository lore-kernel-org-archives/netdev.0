From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.26] [IPV6] Return NET_RX_DROP when a packet is dropped in ipv6_rcv().
Date: Mon, 14 Apr 2008 16:15:54 +0300
Message-ID: <eb3ff54b0804140615u3dd4549fie83ae6818c33beba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_22195_930906.1208178954236"
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "=?BIG5?B?WU9TSElGVUpJIEhpZGVha2kgLyCmTsPDrV6p+g==?="
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:40779 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758741AbYDNNRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 09:17:08 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1571993fgb.17
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2008 06:15:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_22195_930906.1208178954236
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
- The IPv6 handler for receiving packets is ipv6_rcv() in net/ipv6/ip6_input.c.
It is called by netif_receive_skb() (net/core/dev.c)
According to the documentation, the return value of netif_receive_skb() should
be NET_RX_DROP when the packet is dropped; though this return value
is usually not used (except maybe for congestion), this patch fixes the
ipv6_rcv() to return NET_RX_DROP when the packet is dropped (note that
NET_RX_DROP value **is not** 0 but 1; NET_RX_SUCCESS value is in fact	0).


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_22195_930906.1208178954236
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ff12ht7t0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L2lwNl9pbnB1dC5jIGIvbmV0L2lwdjYvaXA2X2lucHV0LmMK
aW5kZXggNGU1Yzg2MS4uM2NhMDQxYiAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvaXA2X2lucHV0LmMK
KysrIGIvbmV0L2lwdjYvaXA2X2lucHV0LmMKQEAgLTEzOCw3ICsxMzgsNyBAQCBkcm9wOgogCXJj
dV9yZWFkX3VubG9jaygpOwogCWtmcmVlX3NrYihza2IpOwogb3V0OgotCXJldHVybiAwOworCXJl
dHVybiBORVRfUlhfRFJPUDsKIH0KIAogLyoK
------=_Part_22195_930906.1208178954236--
