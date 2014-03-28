From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [patch] RDMA/cxgb4: info leak in c4iw_alloc_ucontext()
Date: Fri, 28 Mar 2014 10:58:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6EB791@AcuExch.aculab.com>
References: <20140328082428.GH25192@mwanda>
 <1396002468.3297.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Steve Wise <swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Sean Hefty" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	"dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	"hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org" <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: 'Yann Droneaud' <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1396002468.3297.63.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

RnJvbTogWWFubiBEcm9uZWF1ZA0KPiBIaSwNCj4gDQo+IExlIHZlbmRyZWRpIDI4IG1hcnMgMjAx
NCAgMTE6MjQgKzAzMDAsIERhbiBDYXJwZW50ZXIgYSBjcml0IDoNCj4gPiBUaGUgYzRpd19hbGxv
Y191Y29udGV4dF9yZXNwIHN0cnVjdCBoYXMgYSA0IGJ5dGUgaG9sZSBhZnRlciB0aGUgbGFzdA0K
PiA+IG1lbWJlciBhbmQgd2Ugc2hvdWxkIGNsZWFyIGl0IGJlZm9yZSBwYXNzaW5nIGl0IHRvIHRo
ZSB1c2VyLg0KPiA+DQo+ID4gRml4ZXM6IDA1ZWIyMzg5M2MyYyAoJ2N4Z2I0L2l3X2N4Z2I0OiBE
b29yYmVsbCBEcm9wIEF2b2lkYW5jZSBCdWcgRml4ZXMnKQ0KPiA+IFNpZ25lZC1vZmYtYnk6IERh
biBDYXJwZW50ZXIgPGRhbi5jYXJwZW50ZXJAb3JhY2xlLmNvbT4NCj4gPg0KPiANCj4gSXQncyBu
b3QgdGhlIHByb3BlciBmaXggZm9yIHRoaXMgaXNzdWU6IGFuIGV4cGxpY2l0IHBhZGRpbmcgaGFz
IHRvIGJlDQo+IGFkZGVkIChhbmQgaW5pdGlhbGl6ZWQpLCBzZWUgIlJlOiBbUEFUQ0ggbmV0LW5l
eHQgMi8yXSBjeGdiNC9pd19jeGdiNDoNCj4gRG9vcmJlbGwgRHJvcCBBdm9pZGFuY2UgQnVnIEZp
eGVzIg0KPiBodHRwOi8vbWFyYy5pbmZvLz9pPTEzOTU4NDg5NzcuMzI5Ny4xNS5jYW1lbEBsb2Nh
bGhvc3QubG9jYWxkb21haW4NCj4gDQo+IEluIGl0cyBjdXJyZW50IGZvcm0sIHRoZSBjNGl3X2Fs
bG9jX3Vjb250ZXh0X3Jlc3Agc3RydWN0dXJlIGRvZXMgbm90DQo+IHJlcXVpcmUgcGFkZGluZyBv
biBpMzg2LCBzbyBhIDMyYml0cyB1c2Vyc3BhY2UgcHJvZ3JhbSB1c2luZyB0aGlzDQo+IHN0cnVj
dHVyZSBhZ2FpbnN0IGEgeDg2XzY0IGtlcm5lbCB3aWxsIG1ha2UgdGhlIGtlcm5lbCBkbyBhIGJ1
ZmZlcg0KPiBvdmVyZmxvdyBpbiB1c2Vyc3BhY2UsIGxpa2VseSBvbiBzdGFjaywgYXMgYW5zd2Vy
IG9mIGEgR0VUX0NPTlRFWFQNCj4gcmVxdWVzdDoNCi4uLg0KPiBzdHJ1Y3QgYzRpd19hbGxvY191
Y29udGV4dF9yZXNwIHsNCj4gICAgICAgICBzdHJ1Y3QgaWJ2X2dldF9jb250ZXh0X3Jlc3AgaWJ2
X3Jlc3A7DQo+ICAgICAgICAgX191NjQgc3RhdHVzX3BhZ2Vfa2V5Ow0KPiAgICAgICAgIF9fdTMy
IHN0YXR1c19wYWdlX3NpemU7DQo+IH07DQoNCk9yIGFkZCBfX2F0dHJpYnV0ZV9fKChhbGlnbmVk
KDQpKSkgdG8gdGhlIDY0Yml0IGZpZWxkcy4NCkFuZCBtYXliZSBhIGNvbXBpbGUgdGltZSBhc3Nl
cnQgb24gdGhlIGxlbmd0aCBvZiB0aGUgc3RydWN0dXJlLg0KU2luY2UgaXQgaXMgcGFydCBvZiBh
biBBQkkgaXQgbXVzdCBub3QgY2hhbmdlDQoNCglEYXZpZA0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
