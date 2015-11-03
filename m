From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [net-next v4 3/8] dpaa_eth: add support for S/G frames
Date: Tue, 3 Nov 2015 09:41:14 +0000
Message-ID: <BL2PR03MB5455FAD900C81B20022392CE62B0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
 <1446485500-9782-4-git-send-email-madalin.bucur@freescale.com>
 <1446494829.24485.63.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>, Roy
 Pledge <roy.pledge@freescale.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "ppc@mindchasers.com" <ppc@mindchasers.com>,
 Liberman Igal <Igal.Liberman@freescale.com>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 Scott Wood <scottwood@freescale.com>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1446494829.24485.63.camel@perches.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQo+IEZyb206IEpvZSBQZXJjaGVzIFttYWlsdG86
am9lQHBlcmNoZXMuY29tXQo+IAo+IE9uIE1vbiwgMjAxNS0xMS0wMiBhdCAxOTozMSArMDIwMCwg
TWFkYWxpbiBCdWN1ciB3cm90ZToKPiA+IEFkZCBzdXBwb3J0IGZvciBTY2F0ZXIvR2F0aGVyIChT
L0cpIGZyYW1lcy4gVGhlIEZNYW4gY2FuIHBsYWNlCj4gPiB0aGUgZnJhbWUgY29udGVudCBpbnRv
IG11bHRpcGxlIGJ1ZmZlcnMgYW5kIHByb3ZpZGUgYSBTL0cgVGFibGUKPiA+IChTR1QpIGludG8g
b25lIGZpcnN0IGJ1ZmZlciB3aXRoIHJlZmVyZW5jZXMgdG8gdGhlIG90aGVycy4KPiAKPiB0cml2
aWE6IHNjYXR0ZXIKPiAKPiA+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVl
c2NhbGUvZHBhYS9kcGFhX2V0aF9jb21tb24uYwo+IGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJl
ZXNjYWxlL2RwYWEvZHBhYV9ldGhfY29tbW9uLmMKPiBbXQo+ID4gQEAgLTExNzcsMTAgKzExNzcs
NDIgQEAgdm9pZCBkcGFhX2V0aF9pbml0X3BvcnRzKHN0cnVjdCBtYWNfZGV2aWNlCj4gKm1hY19k
ZXYsCj4gPiAgCQkJICAgICAgcG9ydF9mcXMtPnJ4X2RlZnEsICZidWZfbGF5b3V0W1JYXSk7Cj4g
PiAgfQo+ID4KPiA+ICt2b2lkIGRwYV9yZWxlYXNlX3NndChzdHJ1Y3QgcW1fc2dfZW50cnkgKnNn
dCkKPiA+ICt7Cj4gPiArCXN0cnVjdCBkcGFfYnAgKmRwYV9icDsKPiA+ICsJc3RydWN0IGJtX2J1
ZmZlciBibWJbRFBBX0JVRkZfUkVMRUFTRV9NQVhdOwo+IAo+IFdoZXJlIGlzICJzdHJ1Y3QgYm1f
YnVmZmVyIiBkZWZpbmVkPwo+IAoKVGhhbmsgeW91LCBJJ2xsIGFkZHJlc3MgdGhpcyBhbmQgdGhl
IG90aGVyIG9ic2VydmF0aW9ucyB5b3UgaGF2ZSBzZW50LgpUaGUgc3RydWN0IGJtX2J1ZmZlciBp
cyBkZWZpbmVkIGluIHRoZSBCdWZmZXIgTWFuYWdlciBkcml2ZXIgaGVhZGVyIGZpbGUsCmluIGlu
Y2x1ZGUvc29jL2ZzbC9ibWFuLmguCgpNYWRhbGluCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMt
ZGV2QGxpc3RzLm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xp
bnV4cHBjLWRldg==
