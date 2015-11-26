From: "Dong, Eddie" <eddie.dong-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC PATCH V2 0/3] IXGBE/VFIO: Add live migration support for
 SRIOV NIC
Date: Thu, 26 Nov 2015 03:15:35 +0000
Message-ID: <A12AC9D104E08D47BAF23C492F83C53B25CDE9E3@SHSMSX104.ccr.corp.intel.com>
References: <1448372298-28386-1-git-send-email-tianyu.lan@intel.com>
	<5654722D.4010409@gmail.com>	<56552888.90108@intel.com>
	<CAKgT0UcSrewenfM2YdVojHFFqfK2aVbBN5LH8=BFzc1p0f9hvQ@mail.gmail.com>
	<56556F98.5060507@intel.com>
 <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <a.motakis-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	Alex Williamson <alex.williamson-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org" <b.reynal-lrHrjnjw1UfHK3s98zE1ajGjJy/sRE9J@public.gmane.org>,
	"Bjorn Helgaas" <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"Wyborny, Carolyn" <carolyn.wyborny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Skidmore, Donald C" <donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Jani, Nrupal" <nrupal.jani-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>,
	"kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paolo Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org" <qemu-devel-qX2TKyscuCcdnm+yROfE0A@public.gmane.org>,
	"Tantilov, Emil S" <emil.s.tantilov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Or Gerlitz" <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rustad, Mark D" <mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Auger <eric.auger-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	intel-wired-lan <intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@inte
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Lan, Tianyu" <tianyu.lan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgT0UevBmRLpM1PvuuVDUW79A66RcPrfO8uGiqL1RiALW7apg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBPbiBXZWQsIE5vdiAyNSwgMjAxNSBhdCAxMjoyMSBBTSwgTGFuIFRpYW55dSA8dGlhbnl1Lmxh
bkBpbnRlbC5jb20+IHdyb3RlOg0KPiA+IE9uIDIwMTXlubQxMeaciDI15pelIDEzOjMwLCBBbGV4
YW5kZXIgRHV5Y2sgd3JvdGU6DQo+ID4+IE5vLCB3aGF0IEkgYW0gZ2V0dGluZyBhdCBpcyB0aGF0
IHlvdSBjYW4ndCBnbyBhcm91bmQgYW5kIG1vZGlmeSB0aGUNCj4gPj4gY29uZmlndXJhdGlvbiBz
cGFjZSBmb3IgZXZlcnkgcG9zc2libGUgZGV2aWNlIG91dCB0aGVyZS4gIFRoaXMNCj4gPj4gc29s
dXRpb24gd29uJ3Qgc2NhbGUuDQo+ID4NCj4gPg0KPiA+IFBDSSBjb25maWcgc3BhY2UgcmVncyBh
cmUgZW11bGF0aW9uIGJ5IFFlbXUgYW5kIHNvIFdlIGNhbiBmaW5kIHRoZQ0KPiA+IGZyZWUgUENJ
IGNvbmZpZyBzcGFjZSByZWdzIGZvciB0aGUgZmFrZWQgUENJIGNhcGFiaWxpdHkuIEl0cyBwb3Np
dGlvbg0KPiA+IGNhbiBiZSBub3QgcGVybWFuZW50Lg0KPiANCj4gWWVzLCBidXQgZG8geW91IHJl
YWxseSB3YW50IHRvIGVkaXQgZXZlcnkgZHJpdmVyIG9uIGV2ZXJ5IE9TIHRoYXQgeW91IHBsYW4g
dG8NCj4gc3VwcG9ydCB0aGlzIG9uLiAgV2hhdCBhYm91dCB0aGluZ3MgbGlrZSBkaXJlY3QgYXNz
aWdubWVudCBvZiByZWd1bGFyIEV0aGVybmV0DQo+IHBvcnRzPyAgV2hhdCB5b3UgcmVhbGx5IG5l
ZWQgaXMgYSBzb2x1dGlvbiB0aGF0IHdpbGwgd29yayBnZW5lcmljYWxseSBvbiBhbnkNCj4gZXhp
c3RpbmcgcGllY2Ugb2YgaGFyZHdhcmUgb3V0IHRoZXJlLg0KDQpUaGUgZnVuZGFtZW50YWwgYXNz
dW1wdGlvbiBvZiB0aGlzIHBhdGNoIHNlcmllcyBpcyB0byBtb2RpZnkgdGhlIGRyaXZlciBpbiBn
dWVzdCB0byBzZWxmLWVtdWxhdGUgb3IgdHJhY2sgdGhlIGRldmljZSBzdGF0ZSwgc28gdGhhdCB0
aGUgbWlncmF0aW9uIG1heSBiZSBwb3NzaWJsZS4NCkkgZG9uJ3QgdGhpbmsgd2UgY2FuIG1vZGlm
eSBPUywgd2l0aG91dCBtb2RpZnlpbmcgdGhlIGRyaXZlcnMsIGV2ZW4gdXNpbmcgdGhlIFBDSWUg
aG90cGx1ZyBtZWNoYW5pc20uICANCkluIHRoZSBtZWFudGltZSwgbW9kaWZ5aW5nIFdpbmRvd3Mg
T1MgaXMgYSBiaWcgY2hhbGxlbmdlIGdpdmVuIHRoYXQgb25seSBNaWNyb3NvZnQgY2FuIGRvLiBX
aGlsZSwgbW9kaWZ5aW5nIGRyaXZlciBpcyByZWxhdGl2ZWx5IHNpbXBsZSBhbmQgbWFuYWdlYWJs
ZSB0byBkZXZpY2UgdmVuZG9ycywgaWYgdGhlIGRldmljZSB2ZW5kb3Igd2FudCB0byBzdXBwb3J0
IHN0YXRlLWNsb25lIGJhc2VkIG1pZ3JhdGlvbi4NCg0KVGh4IEVkZGllDQo=
