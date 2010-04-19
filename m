From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] rps: shortcut net_rps_action()
Date: Tue, 20 Apr 2010 07:56:04 +0800
Message-ID: <n2y412e6f7f1004191656qd53a8d77occ407ac288c53bbc@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271583573.16881.4798.camel@edumazet-laptop> <1271590476.16881.4925.camel@edumazet-laptop>
	<1271669822.16881.7520.camel@edumazet-laptop> <k2u412e6f7f1004190248s8ac633beof2475645e799f2ea@mail.gmail.com>
	<1271679244.3845.43.camel@edumazet-laptop> <p2u412e6f7f1004190528l65cc6253w8b7f43f2657b551d@mail.gmail.com>
	<1271683627.3845.44.camel@edumazet-laptop> <1271686957.3845.49.camel@edumazet-laptop>
	<1271689653.3845.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:56486 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab0DSX4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:56:24 -0400
Received: by iwn35 with SMTP id 35so2636750iwn.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:56:24 -0700 (PDT)
In-Reply-To: <1271689653.3845.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gTW9uLCBBcHIgMTksIDIwMTAgYXQgMTE6MDcgUE0sIEVyaWMgRHVtYXpldCA8ZXJpYy5kdW1h
emV0QGdtYWlsLmNvbT4gd3JvdGU6Cj4gKwo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgLyogU2Vu
ZCBwZW5kaW5nIElQSSdzIHRvIGtpY2sgUlBTIHByb2Nlc3Npbmcgb24gcmVtb3RlIGNwdXMuICov
Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCB3aGlsZSAocmVtcXVldWUpIHsKPiArIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHN0cnVjdCBzb2Z0bmV0X2RhdGEgKm5leHQgPSByZW1x
dWV1ZS0+cnBzX2lwaV9uZXh0Owo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
aWYgKGNwdV9vbmxpbmUocmVtcXVldWUtPmNwdSkpCj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBfX3NtcF9jYWxsX2Z1bmN0aW9uX3NpbmdsZShyZW1xdWV1
ZS0+Y3B1LAo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAmcmVtcXVldWUtPmNzZCwg
MCk7Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZW1xdWV1ZSA9IG5leHQ7
Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCB9CgpJdCBzZWVtcyB5b3UgcHJlZmV0Y2ggcnBzX2lw
aV9uZXh0LiBJIHRoaW5rIGl0IGlzbid0IG5lY2Vzc2FyeSwgYXMgdGhlCmxpc3Qgc2hvdWxkIGJl
IHNob3J0LiBJZiB5b3UgaW5zaXN0IG9uIHRoaXMsIGlzIHRoZSBtYWNybyBwcmVmZXRjaCgpCmJl
dHRlcj8KCi0tIApSZWdhcmRz77yMCkNoYW5nbGkgR2FvKHhpYW9zdW9AZ21haWwuY29tKQo=
