From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] rhashtable: use cond_resched()
Date: Thu, 26 Feb 2015 15:36:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEEE09@AcuExch.aculab.com>
References: <CAADnVQKV8JSqhTPYBGDJt4KqTesEvtCMnhupiPyZJjvk=tmOwg@mail.gmail.com>
	 <20150226075354.GA30061@acer.localdomain>
	 <1424962236.5565.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:58748 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbbBZPh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:37:27 -0500
In-Reply-To: <1424964034.5565.162.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IA0KU2VudDogMjYgRmVicnVhcnkgMjAxNSAxNToyMQ0KPiBJZiBh
IGhhc2ggdGFibGUgaGFzIDEyOCBzbG90cyBhbmQgMTYzODQgZWxlbXMsIGV4cGFuZCB0byAyNTYg
c2xvdHMNCj4gdGFrZXMgbW9yZSB0aGFuIG9uZSBzZWNvbmQuIEZvciBsYXJnZXIgc2V0cywgYSBz
b2Z0IGxvY2t1cCBpcyBkZXRlY3RlZC4NCg0KV2hhdCBvbiBlYXJ0aCBpcyBpdCBkb2luZz8NClBy
ZXN1bWFibHkgc29tZXRoaW5nIHRvIGRvIHdpdGggdGhlIHJjdSBhY3Rpb25zIG5lZWRlZCB0byBh
bGxvdw0KbG9ja2xlc3MgbG9va3VwIGR1cmluZyByZXNpemUuDQoNClRoZXJlIGhhcyB0byBiZSBh
IGJldHRlciBzb2x1dGlvbj8NClBlcmhhcHMgZXZlbiB0d28gc2V0cyBvZiBjaGFpbiBwb2ludGVy
cyBkb3duIHRoZSBoYXNoIGxpc3RzLg0KVGhlbiB0aGUgb2xkIGhhc2ggdGFibGUgY2FuIGJlIGtl
cHQgY29tcGxldGVseSB2YWxpZCB3aGlsZSB0aGUNCndob2xlICd1bnppcCcgYWN0aW9uIGlzIGRv
bmUuDQoNCglEYXZpZA0KDQo=
