From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: add per device sg_max_frags for skb
Date: Wed, 6 Jan 2016 13:59:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCBE5AA@AcuExch.aculab.com>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"\"\"Eric W. Biederman\"\"" <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	"\"\"hannes@stressinduktion.org\"\"" <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel
To: 'Hans Westgaard Ry' <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSGFucyBXZXN0Z2FhcmQgUnkNCj4gU2VudDogMDYgSmFudWFyeSAyMDE2IDEzOjE2DQo+
IERldmljZXMgbWF5IGhhdmUgbGltaXRzIG9uIHRoZSBudW1iZXIgb2YgZnJhZ21lbnRzIGluIGFu
IHNrYiB0aGV5DQo+IHN1cHBvcnQuIEN1cnJlbnQgY29kZWJhc2UgdXNlcyBhIGNvbnN0YW50IGFz
IG1heGltdW0gZm9yIG51bWJlciBvZg0KPiBmcmFnbWVudHMgKE1BWF9TS0JfRlJBR1MpIG9uZSBz
a2IgY2FuIGhvbGQgYW5kIHVzZS4NCj4gDQo+IFdoZW4gZW5hYmxpbmcgc2NhdHRlci9nYXRoZXIg
YW5kIHJ1bm5pbmcgdHJhZmZpYyB3aXRoIG1hbnkgc21hbGwNCj4gbWVzc2FnZXMgdGhlIGNvZGVi
YXNlIHVzZXMgdGhlIG1heGltdW0gbnVtYmVyIG9mIGZyYWdtZW50cyBhbmQgdGhlcmVieQ0KPiB2
aW9sYXRlcyB0aGUgbWF4IGZvciBjZXJ0YWluIGRldmljZXMuDQo+IA0KPiBBbiBleGFtcGxlIG9m
IHN1Y2ggYSB2aW9sYXRpb24gaXMgd2hlbiBydW5uaW5nIElQb0lCIG9uIGEgSENBDQo+IHN1cHBv
cnRpbmcgMTYgU0dFIG9uIGFuIGFyY2hpdGVjdHVyZSB3aXRoIDRLIHBhZ2VzaXplLiBUaGUNCj4g
TUFYX1NLQl9GUkFHUyB3aWxsIGJlIDE3ICg2NEsvNEsrMSkgYW5kIGJlY2F1c2UgSVBvSUIgYWRk
cyB5ZXQgYW5vdGhlcg0KPiBzZWdtZW50IHdlIGVuZCB1cCB3aXRoIHNlbmRfcmVxdWVzdHMgd2l0
aCAxOCBTR0UgcmVzdWx0aW5nIGluDQo+IGtlcm5lbC1wYW5pYy4NCj4gDQo+IFRoZSBwYXRjaCBh
bGxvd3MgdGhlIGRldmljZSB0byBsaW1pdCB0aGUgbWF4aW11bSBudW1iZXIgZnJhZ21lbnRzIHVz
ZWQNCj4gaW4gb25lIHNrYi4NCg0KVGhpcyBkb2Vzbid0IHNlZW0gdG8gbWUgdG8gYmUgdGhlIGNv
cnJlY3Qgd2F5IHRvIGZpeCB0aGlzLg0KQW55dGhpbmcgdGhhdCBhZGRzIGFuIGV4dHJhIGZyYWdt
ZW50IChpbiB0aGlzIGNhc2UgSVBvSUIpIHNob3VsZCBhbGxvdw0KZm9yIHRoZSBza2IgYWxyZWFk
eSBoYXZpbmcgdGhlIG1heGltdW0gbnVtYmVyIG9mIGZyYWdtZW50cy4NCkZ1bGx5IGxpbmVhcmlz
aW5nIHRoZSBza2IgaXMgb3ZlcmtpbGwsIGJ1dCBJIHRoaW5rIHRoZSBmaXJzdCBmcmFnbWVudA0K
Y2FuIGJlIGFkZGVkIHRvIHRoZSBsaW5lYXIgcGFydCBvZiB0aGUgc2tiLg0KDQoJRGF2aWQNCg0K
DQo=
