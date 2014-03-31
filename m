From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/5] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Mon, 31 Mar 2014 16:00:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6ECFA7@AcuExch.aculab.com>
References: <1396070947-17721-1-git-send-email-maheshb@google.com>
 <1396281158.29410.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Maciej Zenczykowski" <maze@google.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39744 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752585AbaCaQCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2014 12:02:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31863-03 for <netdev@vger.kernel.org>;
 Mon, 31 Mar 2014 17:01:52 +0100 (BST)
In-Reply-To: <1396281158.29410.41.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQouLi4NCj4gPiArCWlmICghaXNfbXVsdGljYXN0X2V0aGVyX2Fk
ZHIoZXRoX2RhdGEtPmhfZGVzdCkpIHsNCj4gPiArCQlzd2l0Y2ggKG50b2hzKHNrYi0+cHJvdG9j
b2wpKSB7DQo+IA0KPiBOaXQgOg0KPiANCj4gWW91IGNhbiBhdm9pZCB0aGUgbnRvaHMoc2tiLT5w
cm90b2NvbCkNCj4gDQo+ID4gKwkJY2FzZSBFVEhfUF9JUDoNCj4gDQo+IGJ5IHVzaW5nICIgICBj
YXNlIGh0b25zKEVUSF9QX0lQKQ0KPiANCj4gDQo+ID4gKwkJY2FzZSBFVEhfUF9JUFg6IC8qIElu
IGNhc2Ugb2YgSVBYLCBpdCB3aWxsIGZhbGJhY2sgdG8gTDIgaGFzaCAqLw0KPiA+ICsJCWNhc2Ug
RVRIX1BfSVBWNjoNCj4gPiArCQkJaGFzaF9pbmRleCA9IGJvbmRfeG1pdF9oYXNoKGJvbmQsIHNr
Yik7DQo+ID4gKwkJCXR4X3NsYXZlID0gdGxiX2Nob29zZV9jaGFubmVsKGJvbmQsIGhhc2hfaW5k
ZXggJiAweEZGLCBza2ItPmxlbik7DQo+ID4gKwkJCWJyZWFrOw0KPiA+ICsJCX0NCj4gPiArCX0N
Cg0KV2hpY2ggbWF5IG9yIG5vdCBiZSBmYXN0ZXIuLi4NCkFzIGNvZGVkIHRoZSBjYXNlIGxhYmVs
cyBtYXkgYmUgZGVuc2UgZW5vdWdoIHRvIGdlbmVyYXRlIGEganVtcCB0YWJsZS4NCklmIGJ5dGUg
cmV2ZXJzZWQgdGhlIGdlbmVyYXRlZCBjb2RlIHdpbGwgYmUgYSBicmFuY2ggdHJlZS4NCg0KQSBk
ZWVwIGJyYW5jaCB0cmVlIHdpbGwgYmUgd29yc2UsIGEgbWF0Y2ggb24gdGhlIGZpcnN0IGl0ZW0g
b2YgYSBicmFuY2gNCnRyZWUgd2lsbCBhbG1vc3QgY2VydGFpbmx5IGJlIGJldHRlci4NCkknbSBu
b3QgZ29pbmcgdG8gZ3Vlc3Mgd2hlcmUgdGhlIGJyZWFrZXZlbiBwb2ludCBpcyBmb3IgYW55IG1v
ZGVybiBjcHVzLg0KDQoJRGF2aWQNCg0K
