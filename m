From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Fri, 3 Feb 2012 20:24:00 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A823733349A6C9@ORSMSX101.amr.corp.intel.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	 <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>
	 <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com>
 <1328259640.2480.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1328259640.2480.43.camel@edumazet-laptop>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiA+ID4gSGkgU2VhbiwgdGhpcyBpcyB0aGUgcGF0Y2ggcG9zdGVkIGVhcmxpZXIgYnkgRXJpYyBl
bmhhbmNlZCB0bw0KPiA+ID4gaGF2ZSBJUG9JQiB0byBzZXQgZ3JvX21hY19oZWFkZXJfbGVuIHRv
IHRoZSBpcG9pYiBoZWFkZXIgbGVuLCBkb2VzDQo+ID4gPiBpdCBtYWtlIHRoaW5ncyB0byB3b3Jr
IG9rYXkgZm9yIHlvdT8NCj4gPg0KPiA+IEkgcmFuIGEgcXVpY2sgdGVzdC4gIEl0IGhlbHBzIHNv
bWUsIGJ1dCB0aGUgcGVyZm9ybWFuY2UgZm9yIHN0cmVhbWluZw0KPiBwYWNrZXRzIGluIG9uZSBk
aXJlY3Rpb24gaXMgc3RpbGwgb25seSAwLjExIEdicHMuICBJdCBzaG91bGQgYmUgY2xvc2VyIHRv
IDEwLQ0KPiAxNSBHYnBzIGZvciBpcG9pYiBvbiBteSBzeXN0ZW1zLg0KPiA+DQo+ID4gLSBTZWFu
DQo+IA0KPiBIbW0uLi4gYSB0Y3BkdW1wIHdvdWxkIGhlbHAgdG8gdW5kZXJzdGFuZCB3aGF0IGlz
IGdvaW5nIG9uIChmb3IgZXhhbXBsZQ0KPiBpZiBHUk8ga2lja3MgaW4pDQoNCkkgc2hvdWxkIHN0
b3AgdHJ5aW5nIHRvIGFwcGx5IHBhdGNoZXMgc28gbGF0ZS4gIEkgbXVzdCBoYXZlIGRvbmUgc29t
ZXRoaW5nIHdyb25nIHdpdGggbXkgcXVpY2sgdGVzdC4gIFJlLWFwcGx5aW5nIHRoZSBwYXRjaCBv
biAzLjIsIHRoZSBpcG9pYiBVRCBwZXJmb3JtYW5jZSBsb29rcyBva2F5IHRvIG1lIHdpdGggRXJp
YydzIHBhdGNoLiAgU29ycnkgYWJvdXQgdGhlIGZsdWIuDQoNCi0gU2Vhbg0K
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
