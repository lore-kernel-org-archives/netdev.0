From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Xen-devel] Re: [PATCH] ethtool: ETHTOOL_SFEATURES:
 remove NETIF_F_COMPAT return
Date: Sat, 28 May 2011 11:07:08 +0100
Message-ID: <1306577228.23577.17.camel@dagon.hellion.org.uk>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	<20110519100331.GA25103@rere.qmqm.pl>	<20110524091437.GA10779@rere.qmqm.pl>
	<20110524.153930.610330240390616957.davem@davemloft.net>
	<20110524215923.GA20138@rere.qmqm.pl>	<1306505626.2759.4.camel@bwh-desktop>
	<20110527152809.GA7620@rere.qmqm.pl>	<1306511150.2759.17.camel@bwh-desktop>
	<20110527163409.GA8497@rere.qmqm.pl>	<1306538755.2759.31.camel@bwh-desktop>
	<20110528073525.GA19033@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	"xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org" <xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	xen-api-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20110528073525.GA19033-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
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

T24gU2F0LCAyMDExLTA1LTI4IGF0IDA4OjM1ICswMTAwLCBNaWNoYcWCIE1pcm9zxYJhdyB3cm90
ZToKPiBPbiBTYXQsIE1heSAyOCwgMjAxMSBhdCAxMjoyNTo1NUFNICswMTAwLCBCZW4gSHV0Y2hp
bmdzIHdyb3RlOgo+ID4gT24gRnJpLCAyMDExLTA1LTI3IGF0IDE4OjM0ICswMjAwLCBNaWNoYcWC
IE1pcm9zxYJhdyB3cm90ZToKPiA+ID4gT24gRnJpLCBNYXkgMjcsIDIwMTEgYXQgMDQ6NDU6NTBQ
TSArMDEwMCwgQmVuIEh1dGNoaW5ncyB3cm90ZToKPiA+ID4gPiBPbiBGcmksIDIwMTEtMDUtMjcg
YXQgMTc6MjggKzAyMDAsIE1pY2hhxYIgTWlyb3PFgmF3IHdyb3RlOgo+ID4gWy4uLl0KPiA+ID4g
PiA+ICAgICAgKG5vdGU6IEVUSFRPT0xfU3tTRywuLi59IGFyZSBub3QgZXZlciBnb2luZyBhd2F5
KQo+ID4gPiA+ID4gICAgLSBjYXVzZXMgTkVUSUZfRl8qIHRvIGJlIGFuIEFCSQo+ID4gPiA+IElm
IGZlYXR1cmUgZmxhZyBudW1iZXJzIGFyZSBub3Qgc3RhYmxlIHRoZW4gd2hhdCBpcyB0aGUgcG9p
bnQgb2YKPiA+ID4gPiAvc3lzL2NsYXNzL25ldC88bmFtZT4vZmVhdHVyZXM/ICBBbHNvLCBJJ20g
bm90IGF3YXJlIHRoYXQgZmVhdHVyZXMgaGF2ZQo+ID4gPiA+IGV2ZXIgYmVlbiByZW51bWJlcmVk
IGluIHRoZSBwYXN0Lgo+ID4gPiBTaW5jZSBubyBORVRJRl9GXyogd2VyZSBleHBvcnRlZCBlYXJs
aWVyLCBJIGFzc3VtZSAvc3lzL2NsYXNzL25ldC8qL2ZlYXR1cmVzCj4gPiA+IGlzIGEgZGVidWdn
aW5nIGFpZC4gV2hhdCBpcyBpdCB1c2VkIGZvciBiZXNpZGVzIHRoYXQ/Cj4gPiB4ZW4tYXBpIDxo
dHRwczovL2dpdGh1Yi5jb20veGVuLW9yZy94ZW4tYXBpPiB1c2VzIGl0IGluCj4gPiBzY3JpcHRz
L0ludGVyZmFjZVJlY29uZmlndXJlVnN3aXRjaC5weS4gIFRob3VnaCBpdCBkb2Vzbid0IHNlZW0g
dG8gYmUKPiA+IHVzZWQgZm9yIGEgcGFydGljdWxhcmx5IGdvb2QgcmVhc29uLi4uCj4gCj4gTG9v
ayBsaWtlIGl0IHNob3VsZCB1c2UgRVRIVE9PTF9HRkxBR1MgaW5zdGVhZCBmb3IgbmV0ZGV2X2hh
c192bGFuX2FjY2VsKCkuCj4gCj4gQmVzdCBSZWdhcmRzLAo+IE1pY2hhxYIgTWlyb3PFgmF3Cj4g
Cj4gW2FkZGVkIENjOiB4ZW4tZGV2ZWxdCgphZGRlZCBDYzogeGVuLWFwaSBsaXN0IGFuZCBkZXZA
b3BlbnZzd2l0Y2ggYXMgd2VsbC4KCkNvbXBsZXRlIHRocmVhZCBpcyBhdApodHRwOi8vdGhyZWFk
LmdtYW5lLm9yZy9nbWFuZS5saW51eC5uZXR3b3JrLzE5NTU1Mi9mb2N1cz0xOTcwMTkKCklhbi4K
CgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFp
bGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWls
bWFuL2xpc3RpbmZvL2Rldgo=
