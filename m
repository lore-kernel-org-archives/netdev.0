From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH 2/3] xen: modify xenstore watch event
	interface
Date: Fri, 6 Jan 2017 16:57:31 -0500
Message-ID: <c4a181ac-ca47-16bd-5b3d-ea25e413355f@oracle.com>
References: <20170106150544.10836-1-jgross@suse.com>
 <20170106150544.10836-3-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, roger.pau@citrix.com, wei.liu2@citrix.com,
 paul.durrant@citrix.com
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
 xen-devel@lists.xenproject.org
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20170106150544.10836-3-jgross@suse.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

T24gMDEvMDYvMjAxNyAxMDowNSBBTSwgSnVlcmdlbiBHcm9zcyB3cm90ZToKPiBUb2RheSBhIFhl
bnN0b3JlIHdhdGNoIGV2ZW50IGlzIGRlbGl2ZXJlZCB2aWEgYSBjYWxsYmFjayBmdW5jdGlvbgo+
IGRlY2xhcmVkIGFzOgo+Cj4gdm9pZCAoKmNhbGxiYWNrKShzdHJ1Y3QgeGVuYnVzX3dhdGNoICos
Cj4gICAgICAgICAgICAgICAgICBjb25zdCBjaGFyICoqdmVjLCB1bnNpZ25lZCBpbnQgbGVuKTsK
Pgo+IEFzIGFsbCB3YXRjaCBldmVudHMgb25seSBldmVyIGNvbWUgd2l0aCB0d28gcGFyYW1ldGVy
cyAocGF0aCBhbmQgdG9rZW4pCj4gY2hhbmdpbmcgdGhlIHByb3RvdHlwZSB0bzoKPgo+IHZvaWQg
KCpjYWxsYmFjaykoc3RydWN0IHhlbmJ1c193YXRjaCAqLAo+ICAgICAgICAgICAgICAgICAgY29u
c3QgY2hhciAqcGF0aCwgY29uc3QgY2hhciAqdG9rZW4pOwo+Cj4gaXMgdGhlIG5hdHVyYWwgdGhp
bmcgdG8gZG8uCj4KPiBBcHBseSB0aGlzIGNoYW5nZSBhbmQgYWRhcHQgYWxsIHVzZXJzLgo+Cj4g
Q2M6IGtvbnJhZC53aWxrQG9yYWNsZS5jb20KPiBDYzogcm9nZXIucGF1QGNpdHJpeC5jb20KPiBD
Yzogd2VpLmxpdTJAY2l0cml4LmNvbQo+IENjOiBwYXVsLmR1cnJhbnRAY2l0cml4LmNvbQo+IENj
OiBuZXRkZXZAdmdlci5rZXJuZWwub3JnCj4KPiBTaWduZWQtb2ZmLWJ5OiBKdWVyZ2VuIEdyb3Nz
IDxqZ3Jvc3NAc3VzZS5jb20+CgoKPiAgCj4gQEAgLTkwMywyNCArOTAyLDI0IEBAIHN0YXRpYyBp
bnQgcHJvY2Vzc19tc2codm9pZCkKPiAgCWJvZHlbbXNnLT5oZHIubGVuXSA9ICdcMCc7Cj4gIAo+
ICAJaWYgKG1zZy0+aGRyLnR5cGUgPT0gWFNfV0FUQ0hfRVZFTlQpIHsKPiAtCQltc2ctPnUud2F0
Y2gudmVjID0gc3BsaXQoYm9keSwgbXNnLT5oZHIubGVuLAo+IC0JCQkJCSAmbXNnLT51LndhdGNo
LnZlY19zaXplKTsKPiAtCQlpZiAoSVNfRVJSKG1zZy0+dS53YXRjaC52ZWMpKSB7Cj4gLQkJCWVy
ciA9IFBUUl9FUlIobXNnLT51LndhdGNoLnZlYyk7Cj4gKwkJaWYgKGNvdW50X3N0cmluZ3MoYm9k
eSwgbXNnLT5oZHIubGVuKSAhPSAyKSB7Cj4gKwkJCWVyciA9IC1FSU5WQUw7Cgp4ZW5idXNfd3Jp
dGVfd2F0Y2goKSByZXR1cm5zIC1FSUxTRVEgd2hlbiB0aGlzIHR5cGUgb2YgZXJyb3IgaXMKZW5j
b3VudGVyZWQgc28gcGVyaGFwcyBmb3Igd2Ugc2hvdWxkIHJldHVybiB0aGUgc2FtZSBlcnJvciBo
ZXJlLgoKRWl0aGVyIHdheQoKUmV2aWV3ZWQtYnk6IEJvcmlzIE9zdHJvdnNreSA8Ym9yaXMub3N0
cm92c2t5QG9yYWNsZS5jb20+CgoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbi5v
cmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
