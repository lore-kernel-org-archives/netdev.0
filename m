From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reorganize sk_buff for faster
 __copy_skb_header()
Date: Mon, 29 Sep 2014 00:06:11 -0400 (EDT)
Message-ID: <20140929.000611.1697245481977504922.davem@davemloft.net>
References: <1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140928.173759.584339934179620924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	john.r.fastabend@intel.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaI2EGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 00:06:13 -0400
In-Reply-To: <20140928.173759.584339934179620924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogU3VuLCAyOCBT
ZXAgMjAxNCAxNzozNzo1OSAtMDQwMCAoRURUKQ0KDQo+IEFwcGxpZWQsIHRoYW5rcyENCg0KRXJp
YywgSSBoYWQgdG8gcmV2ZXJ0LiAgUGxlYXNlIGVuYWJsZSBJUFZTIGluIHlvdXIgYnVpbGQgdGVz
dHMuDQoNCm5ldC9pcHY0L2lwX291dHB1dC5jOiBJbiBmdW5jdGlvbiChaXBfY29weV9tZXRhZGF0
YaI6DQpuZXQvaXB2NC9pcF9vdXRwdXQuYzo0NzA6NDogZXJyb3I6IKFzdHJ1Y3Qgc2tfYnVmZqIg
aGFzIG5vIG1lbWJlciBuYW1lZCChaXB2c19wcm9wZXJ0eaINCiAgdG8tPmlwdnNfcHJvcGVydHkg
PSBmcm9tLT5pcHZzX3Byb3BlcnR5Ow0KICAgIF4NCm5ldC9pcHY0L2lwX291dHB1dC5jOjQ3MDoy
NjogZXJyb3I6IKFzdHJ1Y3Qgc2tfYnVmZqIgaGFzIG5vIG1lbWJlciBuYW1lZCChaXB2c19wcm9w
ZXJ0eaINCiAgdG8tPmlwdnNfcHJvcGVydHkgPSBmcm9tLT5pcHZzX3Byb3BlcnR5Ow0KICAgICAg
ICAgICAgICAgICAgICAgICAgICBeDQo=
