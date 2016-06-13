From: Steven Caron <steven.caron@genband.com>
Subject: [PATCH v1 1/1] ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Mon, 13 Jun 2016 14:01:19 +0000
Message-ID: <6A051441C8B95A448E49718A747690B901CA76C84F@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Linux Kernel Network Developers" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-181.mimecast.com ([63.128.21.181]:40235 "EHLO
	us-smtp-delivery-181.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423933AbcFMOCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 10:02:01 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpBcyAgdGhlIGlwIGZyYWdtZW50IG9mZnNldCBmaWVsZCBjb3VudHMgOC1ieXRlIGNodW5rcywg
bm9uLWZpbmFsIGlwDQpmcmFnbWVudHMgbXVzdCBiZSBtdWx0aXBsZXMgb2YgOCBieXRlcyBvZiBw
YXlsb2FkLiBEZXBlbmRpbmcgIG9uIHRoZQ0KbXR1IGFuZCBpcCBvcHRpb24gc2l6ZXMsIGlwX2Fw
cGVuZF9wYWdlIHdhc24ndCByZXNwZWN0aW5nIHRoaXMsDQpub3RhYmx5IHdoZW4gcnVubmluZyBO
RlMgdW5kZXIgVURQLg0KDQpTaWduZWQtb2ZmLWJ5OiBTdGV2ZW4gQ2Fyb24gPHN0ZXZlbi5jYXJv
bkBnZW5iYW5kLmNvbT4NCi0tLQ0KZGlmZiAtLWdpdCBhL25ldC9pcHY0L2lwX291dHB1dC5jIGIv
bmV0L2lwdjQvaXBfb3V0cHV0LmMgaW5kZXggMTI0YmYwYS4uMjFlYzU0ZSAxMDA2NDQNCi0tLSBh
L25ldC9pcHY0L2lwX291dHB1dC5jDQorKysgYi9uZXQvaXB2NC9pcF9vdXRwdXQuYw0KQEAgLTEy
MzksNyArMTIzOSw3IEBAIHNzaXplX3QgICBpcF9hcHBlbmRfcGFnZShzdHJ1Y3Qgc29jayAqc2ss
IHN0cnVjdCBmbG93aTQgKmZsNCwgc3RydWN0IHBhZ2UgKnBhZ2UsDQogICAgICAgICAgICAgICAg
aWYgKHNrYi0+aXBfc3VtbWVkICE9IENIRUNLU1VNX1BBUlRJQUwpDQogICAgICAgICAgICAgICAg
ICAgICAgICByZXR1cm4gLUVPUE5PVFNVUFA7DQoNCi0gICAgICAgICAgICAgICBza2Jfc2hpbmZv
KHNrYiktPmdzb19zaXplID0gbXR1IC0gZnJhZ2hlYWRlcmxlbjsNCisgICAgICAgICAgICAgICBz
a2Jfc2hpbmZvKHNrYiktPmdzb19zaXplID0gbWF4ZnJhZ2xlbiAtIGZyYWdoZWFkZXJsZW47DQog
ICAgICAgICAgICAgICAgc2tiX3NoaW5mbyhza2IpLT5nc29fdHlwZSA9IFNLQl9HU09fVURQOw0K
ICAgICAgICB9DQogICAgICAgIGNvcmstPmxlbmd0aCArPSBzaXplOw0K
