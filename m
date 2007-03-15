From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 2/3] [IPV6]: Reset the network header in ip6_nd_hdr
Date: Wed, 14 Mar 2007 21:32:08 -0300
Message-ID: <39e6f6c70703141732k436e06c0oe65088d54c2f4cd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_52965_33056437.1173918728206"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.238]:40894 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422780AbXCOAcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 20:32:12 -0400
Received: by wr-out-0506.google.com with SMTP id i28so384227wra
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 17:32:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_52965_33056437.1173918728206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

ip6_nd_hdr is always called immediately after a alloc_skb + skb_reserve
sequence, i.e. when skb->tail is equal to skb->data, making it correct to use
skb_reset_network_header().

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/ipv6/ip6_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

------=_Part_52965_33056437.1173918728206
Content-Type: text/x-patch;
	name=0002-IPV6-Reset-the-network-header-in-ip6_nd_hdr.patch;
	charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ezagtf9f
Content-Disposition: attachment; filename="0002-IPV6-Reset-the-network-header-in-ip6_nd_hdr.patch"

RnJvbSA3NTkyZjM5MThlYTJkMjJmZGEyMjI5YmRhMzNiY2FjOGEwNTE4NGI2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcm5hbGRvIENhcnZhbGhvIGRlIE1lbG8gPGFjbWVAcmVkaGF0
LmNvbT4KRGF0ZTogV2VkLCAxNCBNYXIgMjAwNyAyMTowNTowMyAtMDMwMApTdWJqZWN0OiBbUEFU
Q0ggMi8zXSBbSVBWNl06IFJlc2V0IHRoZSBuZXR3b3JrIGhlYWRlciBpbiBpcDZfbmRfaGRyCgpp
cDZfbmRfaGRyIGlzIGFsd2F5cyBjYWxsZWQgaW1tZWRpYXRlbHkgYWZ0ZXIgYSBhbGxvY19za2Ig
KyBza2JfcmVzZXJ2ZQpzZXF1ZW5jZSwgaS5lLiB3aGVuIHNrYi0+dGFpbCBpcyBlcXVhbCB0byBz
a2ItPmRhdGEsIG1ha2luZyBpdCBjb3JyZWN0IHRvIHVzZQpza2JfcmVzZXRfbmV0d29ya19oZWFk
ZXIoKS4KClNpZ25lZC1vZmYtYnk6IEFybmFsZG8gQ2FydmFsaG8gZGUgTWVsbyA8YWNtZUByZWRo
YXQuY29tPgotLS0KIG5ldC9pcHY2L2lwNl9vdXRwdXQuYyB8ICAgIDMgKystCiAxIGZpbGVzIGNo
YW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQv
aXB2Ni9pcDZfb3V0cHV0LmMgYi9uZXQvaXB2Ni9pcDZfb3V0cHV0LmMKaW5kZXggNDk1MjNjMi4u
MzJlOGMzZiAxMDA2NDQKLS0tIGEvbmV0L2lwdjYvaXA2X291dHB1dC5jCisrKyBiL25ldC9pcHY2
L2lwNl9vdXRwdXQuYwpAQCAtMjYzLDcgKzI2Myw4IEBAIGludCBpcDZfbmRfaGRyKHN0cnVjdCBz
b2NrICpzaywgc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKIAog
CXRvdGxlbiA9IGxlbiArIHNpemVvZihzdHJ1Y3QgaXB2Nmhkcik7CiAKLQlza2ItPm5oLnJhdyA9
IHNrYl9wdXQoc2tiLCBzaXplb2Yoc3RydWN0IGlwdjZoZHIpKTsKKwlza2JfcmVzZXRfbmV0d29y
a19oZWFkZXIoc2tiKTsKKwlza2JfcHV0KHNrYiwgc2l6ZW9mKHN0cnVjdCBpcHY2aGRyKSk7CiAJ
aGRyID0gaXB2Nl9oZHIoc2tiKTsKIAogCSooX19iZTMyKiloZHIgPSBodG9ubCgweDYwMDAwMDAw
KTsKLS0gCjEuNS4wLjIKCg==
------=_Part_52965_33056437.1173918728206--
