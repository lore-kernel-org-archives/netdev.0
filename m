From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 1/2]
	include/uapi/linux/xfrm.h: Pack struct xfrm_userpolicy_info
Date: Thu, 9 Jan 2014 16:39:46 +0800
Message-ID: <52CE6052.5030905@windriver.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
	<1389077339-12814-2-git-send-email-fan.du@windriver.com>
	<52CC851B.2060401@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: steffen.klassert@secunet.com, stephen@networkplumber.org,
	davem@davemloft.net, dev@lists.strongswan.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org>
In-Reply-To: <52CC851B.2060401@cogentembedded.com>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.strongswan.org>
List-Help: <mailto:dev-request@lists.strongswan.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=subscribe>
Sender: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
Errors-To: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
List-Id: netdev.vger.kernel.org

CgpPbiAyMDE05bm0MDHmnIgwOOaXpSAwNjo1MiwgU2VyZ2VpIFNodHlseW92IHdyb3RlOgo+IEhl
bGxvLgo+Cj4gT24gMDctMDEtMjAxNCAxMDo0OCwgRmFuIER1IHdyb3RlOgo+Cj4+IE90aGVyd2lz
ZSA2NGJpdHMga2VybmVsIGhhcyBzaXplb2Yoc3RydWN0IHhmcm1fdXNlcnBvbGljeV9pbmZvKSAx
NjggYnl0ZXMsCj4+IHdoaWxlIDMyYml0cyBjb21waWxlZCBpcHJvdXRlMiBzZWUgdGhlIHNhbWUg
c3RydWN0dXJlIGFzIDE2NCBieXRlcywgd2hpY2gKPj4gbGVhZGluZyBkZWZpY2l0IHhmcm0gcG9s
aWN5LCBpbiB0dXJuIGJyb2tlbiBJUHNlYyBjb25uZWN0aXZpdHkuCj4KPj4gRml4IHRoaXMgYnkg
cGFja2luZyB0aGUgc3RydWN0dXJlLgo+Cj4gICAgIFRoaXMgd2lsbCBmb3JjZSBieXRlLWJ5LWJ5
dGUgYWNjZXNzIHRvIGFsbCBtZW1iZXJzIG9uIHNvbWUgYXJjaGVzIGxpa2UgQVJNLi4uCj4KPj4g
U2lnbmVkLW9mZi1ieTogRmFuIER1IDxmYW4uZHVAd2luZHJpdmVyLmNvbT4KPj4gLS0tCj4+ICAg
aW5jbHVkZS91YXBpL2xpbnV4L3hmcm0uaCB8ICAgIDIgKy0KPj4gICAxIGZpbGUgY2hhbmdlZCwg
MSBpbnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkKPgo+PiBkaWZmIC0tZ2l0IGEvaW5jbHVkZS91
YXBpL2xpbnV4L3hmcm0uaCBiL2luY2x1ZGUvdWFwaS9saW51eC94ZnJtLmgKPj4gaW5kZXggYThj
ZDZhNC4uNDcwYmZhZSAxMDA2NDQKPj4gLS0tIGEvaW5jbHVkZS91YXBpL2xpbnV4L3hmcm0uaAo+
PiArKysgYi9pbmNsdWRlL3VhcGkvbGludXgveGZybS5oCj4+IEBAIC00MDUsNyArNDA1LDcgQEAg
c3RydWN0IHhmcm1fdXNlcnBvbGljeV9pbmZvIHsKPj4gICAgICAgLyogQXV0b21hdGljYWxseSBl
eHBhbmQgc2VsZWN0b3IgdG8gaW5jbHVkZSBtYXRjaGluZyBJQ01QIHBheWxvYWRzLiAqLwo+PiAg
ICNkZWZpbmUgWEZSTV9QT0xJQ1lfSUNNUCAgICAyCj4+ICAgICAgIF9fdTggICAgICAgICAgICAg
ICAgc2hhcmU7Cj4+IC19Owo+PiArfSBfX2F0dHJpYnV0ZV9fKChwYWNrZWQpKTsKPgo+ICAgICBQ
bGVhc2UgdXNlIHRoZSBfX3BhY2tlZCBtYWNybyBpbnN0ZWFkLiBJIGd1ZXNzIHlvdSBoYXZlbid0
IHJ1biBjaGVja3BhdGNoLnBsPwoKTHVja3kgbWUsIEkgcnVuIGNoZWNrcGF0Y2ggZXZlcnkgdGlt
ZSBiZWZvcmUgc2VuZGluZyBwYXRjaCBvdXQuCgotLSAK5rWu5rKJ6ZqP5rWq5Y+q6K6w5LuK5pyd
56yRCgotLWZhbgoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X18KRGV2IG1haWxpbmcgbGlzdApEZXZAbGlzdHMuc3Ryb25nc3dhbi5vcmcKaHR0cHM6Ly9saXN0
cy5zdHJvbmdzd2FuLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldg==
