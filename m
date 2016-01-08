From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: add per device sg_max_frags for skb
Date: Fri, 8 Jan 2016 10:33:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCC00C7@AcuExch.aculab.com>
References: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCBE5AA@AcuExch.aculab.com>
 <568F87AC.60405@oracle.com>
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
	"Eric W. Biederman " <ebiederm@xmission.com>,
	Salam Noureddine <noureddine@arista.com>,
	Jarod Wilson <jarod@redhat.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Julian Anastasov <ja@ssi.bg>,
	Ying Xue <ying.xue@windriver.com>,
	Craig Gallek <kraig@google.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	"\" hannes\"@stressinduktion.org " <hannes@stressinduktion.org>,
	Edward Jee <edjee@google.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <li
To: 'Hans Westgaard Ry' <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <568F87AC.60405@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogSGFucyBXZXN0Z2FhcmQNCj4gU2VudDogMDggSmFudWFyeSAyMDE2IDA5OjU2DQouLi4N
Cj4gPj4gVGhlIHBhdGNoIGFsbG93cyB0aGUgZGV2aWNlIHRvIGxpbWl0IHRoZSBtYXhpbXVtIG51
bWJlciBmcmFnbWVudHMgdXNlZA0KPiA+PiBpbiBvbmUgc2tiLg0KPiA+DQo+ID4gVGhpcyBkb2Vz
bid0IHNlZW0gdG8gbWUgdG8gYmUgdGhlIGNvcnJlY3Qgd2F5IHRvIGZpeCB0aGlzLg0KPiA+IEFu
eXRoaW5nIHRoYXQgYWRkcyBhbiBleHRyYSBmcmFnbWVudCAoaW4gdGhpcyBjYXNlIElQb0lCKSBz
aG91bGQgYWxsb3cNCj4gPiBmb3IgdGhlIHNrYiBhbHJlYWR5IGhhdmluZyB0aGUgbWF4aW11bSBu
dW1iZXIgb2YgZnJhZ21lbnRzLg0KPiA+IEZ1bGx5IGxpbmVhcmlzaW5nIHRoZSBza2IgaXMgb3Zl
cmtpbGwsIGJ1dCBJIHRoaW5rIHRoZSBmaXJzdCBmcmFnbWVudA0KPiA+IGNhbiBiZSBhZGRlZCB0
byB0aGUgbGluZWFyIHBhcnQgb2YgdGhlIHNrYi4NCj4gPg0KPiA+IAlEYXZpZA0KPiA+DQo+ID4N
Cj4gV2hlbiBJcG9JQiBoYW5kbGVzIGEgc2tiLXJlcXVlc3QgaXQgY29udmVydHMgZnJhZ21lbnRz
IHRvIFNHRXMgdG8NCj4gYmUgaGFuZGxlZCBieSBhIEhDQS4NCj4gVGhlIHByb2JsZW0gYXJpc2Vz
IHdoZW4gdGhlIEhDQSBoYXZlIGEgbGltaXRlZCBudW1iZXIgb2YgU0dFcyBsZXNzIHRoYW4NCj4g
TUFYX1NLQl9GUkFHUy4NCj4gKGl0IGdldHMgYSBsaXR0bGUgd29yc2Ugc2luY2UgSVBvSUIgbmVl
ZCB0byB5ZXQgYW5vdGhlciBzZWdtZW50KQ0KPiBJIGhhdmUgbm90IGZvdW5kIGFueSBlYXN5IHdh
eSBvZiBmaXhpbmcgdGhpcyB3aXRoIGN1cnJlbmN0IGNvZGViYXNlLg0KDQpJIHRoaW5rIG9uZSBv
ZiB0aGUgeGVuIGV0aGVybmV0IGludGVyZmFjZXMgaGFkIGEgc2ltaWxhciBwcm9ibGVtLg0KDQpK
dXN0IHJlZHVjZSB0aGUgbnVtYmVyIG9mIGZyYWdtZW50cyBieSBjb3B5aW5nIHR3byAob3IgbW9y
ZSkgb2YgdGhlbQ0KaW50byBhIHNpbmdsZSBmcmFnbWVudC4NCkluIGVmZmVjdCwgYW55dGhpbmcg
dGhhdCByZWR1Y2VzIHRoZSBudW1iZXIgb2YgZnJhZ21lbnRzIHdpbGwgZG8gYSBjb3B5Lg0KDQoJ
RGF2aWQNCg0K
