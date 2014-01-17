From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] reciprocal_divide: correction/update of
 the algorithm
Date: Fri, 17 Jan 2014 10:05:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D45EB06@AcuExch.aculab.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
 <1389828228-30312-3-git-send-email-dborkman@redhat.com>
 <alpine.DEB.2.10.1401161036110.29778@nuc>
 <20140116172406.GA17529@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	"Jesse Gross" <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	"Pekka Enberg" <penberg@kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	"Veaceslav Falico" <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: 'Hannes Frederic Sowa' <hannes@stressinduktion.org>,
	Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39699 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752374AbaAQKHy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 05:07:54 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08492-03 for <netdev@vger.kernel.org>;
 Fri, 17 Jan 2014 10:07:50 +0000 (GMT)
In-Reply-To: <20140116172406.GA17529@order.stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGFubmVzIEZyZWRlcmljIFNvd2ENCj4gT24gVGh1LCBKYW4gMTYsIDIwMTQgYXQgMTA6
Mzc6MzdBTSAtMDYwMCwgQ2hyaXN0b3BoIExhbWV0ZXIgd3JvdGU6DQo+ID4gT24gVGh1LCAxNiBK
YW4gMjAxNCwgRGFuaWVsIEJvcmttYW5uIHdyb3RlOg0KPiA+DQo+ID4gPiAtICogb3IgZWxzZSB0
aGUgcGVyZm9ybWFuY2UgaXMgc2xvd2VyIHRoYW4gYSBub3JtYWwgZGl2aWRlLg0KPiA+ID4gLSAq
Lw0KPiA+ID4gLWV4dGVybiB1MzIgcmVjaXByb2NhbF92YWx1ZSh1MzIgQik7DQo+ID4gPiArc3Ry
dWN0IHJlY2lwcm9jYWxfdmFsdWUgew0KPiA+ID4gKwl1MzIgbTsNCj4gPiA+ICsJdTggc2gxLCBz
aDI7DQo+ID4gPiArfTsNCj4gPiA+DQo+ID4gPiArI2RlZmluZSBSRUNJUFJPQ0FMX1ZBTFVFX1JF
U1VMVF9UT19aRVJPICgoc3RydWN0IHJlY2lwcm9jYWxfdmFsdWUpey5zaDEgPSAzMn0pDQo+ID4g
Pg0KPiA+ID4gLXN0YXRpYyBpbmxpbmUgdTMyIHJlY2lwcm9jYWxfZGl2aWRlKHUzMiBBLCB1MzIg
UikNCj4gPiA+ICtzdHJ1Y3QgcmVjaXByb2NhbF92YWx1ZSByZWNpcHJvY2FsX3ZhbHVlKHUzMiBk
KTsNCj4gPg0KPiA+IEEgZnVuY3Rpb24gdGhhdCByZXR1cm5zIGEgc3RydWN0PyBUaGF0IHdvcmtz
PyBXaGljaCBnY2MgdmVyc2lvbnMgc3VwcG9ydA0KPiA+IGl0Pw0KPiANCj4gU3VyZSwgdGhhdCB3
b3JrcyBhbmQgSSBhY3R1YWxseSBsaWtlIGl0LiBUaGlzIGlzIHN1cHBvcnRlZCBieSB0aGUgYyBz
dGFuZGFyZCwNCj4gYnV0IHBsZWFzZSBkb24ndCBhc2sgbWUgc2luY2Ugd2hpY2ggb25lLiA7KQ0K
DQpJIHRoaW5rIGl0IGhhcyBhbHdheXMgYmVlbiBzdXBwb3J0ZWQuDQpPcmlnaW5hbGx5IGJ5IGFk
ZGluZyBhbiBleHRyYSBoaWRkZW4gYXJndW1lbnQgdGhhdCBwb2ludHMgdG8gYW4gb24tc3RhY2sN
CnN0cnVjdHVyZS4NCk1vcmUgcmVjZW50IEFCSSB0ZW5kIHRvIGFsbG93ICdzbWFsbCcgc3RydWN0
dXJlcyBiZSByZXR1cm5lZCBpbiByZWdpc3RlcnMuDQooVHlwaWNhbGx5IG9uZXMgdGhhdCB3b3Vs
ZCBmaXQgaW4gdGhlIHJlZ2lzdGVyKHMpIHVzZWQgZm9yIGFuIGludGVncmFsIHJlc3VsdCkuDQoN
ClRoaXMgZG9lc24ndCBtZWFuIHRoYXQgaXQgaXMgYSBnb29kIGlkZWEhDQoNCk9UT0ggaWYgdGhl
IGZ1bmN0aW9uIGlzICdzdGF0aWMgaW5saW5lJyAoYW5kIGlubGluZWQpIGl0IHByb2JhYmx5IGRv
ZXNuJ3QgbWF0dGVyLg0KDQoJRGF2aWQNCg0K
