From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Xen-devel] Re: [PATCH] ethtool: ETHTOOL_SFEATURES:
 remove NETIF_F_COMPAT return
Date: Sat, 28 May 2011 10:31:03 -0700
Message-ID: <BANLkTime8PHYe+BFELt92gg7SZ91xKvAwA@mail.gmail.com>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	<20110519100331.GA25103@rere.qmqm.pl>
	<20110524091437.GA10779@rere.qmqm.pl>
	<20110524.153930.610330240390616957.davem@davemloft.net>
	<20110524215923.GA20138@rere.qmqm.pl>
	<1306505626.2759.4.camel@bwh-desktop>
	<20110527152809.GA7620@rere.qmqm.pl>
	<1306511150.2759.17.camel@bwh-desktop>
	<20110527163409.GA8497@rere.qmqm.pl>
	<1306538755.2759.31.camel@bwh-desktop>
	<20110528073525.GA19033@rere.qmqm.pl>
	<1306577228.23577.17.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	"xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org" <xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	xen-api-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	=?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1306577228.23577.17.camel-ztPmHsLffjjnO4AKDKe2m+kiAK3p4hvP@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

MjAxMS81LzI4IElhbiBDYW1wYmVsbCA8SWFuLkNhbXBiZWxsQGNpdHJpeC5jb20+Ogo+IE9uIFNh
dCwgMjAxMS0wNS0yOCBhdCAwODozNSArMDEwMCwgTWljaGHFgiBNaXJvc8WCYXcgd3JvdGU6Cj4+
IE9uIFNhdCwgTWF5IDI4LCAyMDExIGF0IDEyOjI1OjU1QU0gKzAxMDAsIEJlbiBIdXRjaGluZ3Mg
d3JvdGU6Cj4+ID4gT24gRnJpLCAyMDExLTA1LTI3IGF0IDE4OjM0ICswMjAwLCBNaWNoYcWCIE1p
cm9zxYJhdyB3cm90ZToKPj4gPiA+IE9uIEZyaSwgTWF5IDI3LCAyMDExIGF0IDA0OjQ1OjUwUE0g
KzAxMDAsIEJlbiBIdXRjaGluZ3Mgd3JvdGU6Cj4+ID4gPiA+IE9uIEZyaSwgMjAxMS0wNS0yNyBh
dCAxNzoyOCArMDIwMCwgTWljaGHFgiBNaXJvc8WCYXcgd3JvdGU6Cj4+ID4gWy4uLl0KPj4gPiA+
ID4gPiDCoCDCoCDCoChub3RlOiBFVEhUT09MX1N7U0csLi4ufSBhcmUgbm90IGV2ZXIgZ29pbmcg
YXdheSkKPj4gPiA+ID4gPiDCoCDCoC0gY2F1c2VzIE5FVElGX0ZfKiB0byBiZSBhbiBBQkkKPj4g
PiA+ID4gSWYgZmVhdHVyZSBmbGFnIG51bWJlcnMgYXJlIG5vdCBzdGFibGUgdGhlbiB3aGF0IGlz
IHRoZSBwb2ludCBvZgo+PiA+ID4gPiAvc3lzL2NsYXNzL25ldC88bmFtZT4vZmVhdHVyZXM/IMKg
QWxzbywgSSdtIG5vdCBhd2FyZSB0aGF0IGZlYXR1cmVzIGhhdmUKPj4gPiA+ID4gZXZlciBiZWVu
IHJlbnVtYmVyZWQgaW4gdGhlIHBhc3QuCj4+ID4gPiBTaW5jZSBubyBORVRJRl9GXyogd2VyZSBl
eHBvcnRlZCBlYXJsaWVyLCBJIGFzc3VtZSAvc3lzL2NsYXNzL25ldC8qL2ZlYXR1cmVzCj4+ID4g
PiBpcyBhIGRlYnVnZ2luZyBhaWQuIFdoYXQgaXMgaXQgdXNlZCBmb3IgYmVzaWRlcyB0aGF0Pwo+
PiA+IHhlbi1hcGkgPGh0dHBzOi8vZ2l0aHViLmNvbS94ZW4tb3JnL3hlbi1hcGk+IHVzZXMgaXQg
aW4KPj4gPiBzY3JpcHRzL0ludGVyZmFjZVJlY29uZmlndXJlVnN3aXRjaC5weS4gwqBUaG91Z2gg
aXQgZG9lc24ndCBzZWVtIHRvIGJlCj4+ID4gdXNlZCBmb3IgYSBwYXJ0aWN1bGFybHkgZ29vZCBy
ZWFzb24uLi4KPj4KPj4gTG9vayBsaWtlIGl0IHNob3VsZCB1c2UgRVRIVE9PTF9HRkxBR1MgaW5z
dGVhZCBmb3IgbmV0ZGV2X2hhc192bGFuX2FjY2VsKCkuCgpFVEhUT09MX0dGTEFHUyBkaWRuJ3Qg
ZXhwb3NlIHRoZSB2bGFuIGFjY2VsZXJhdGlvbiBmbGFncyB1bnRpbCAyLjYuMzcsCndoaWNoIGlz
IHdoeSAvc3lzL2NsYXNzL25ldCB3YXMgdXNlZCBpbnN0ZWFkLgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3
aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
