From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and
 ib_uverbs_query_port()
Date: Tue, 7 Apr 2015 18:49:52 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523CF30.7000608@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Tucker <tom-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Hoang-Nam Nguyen <hnguyen-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Christoph Raisch <raisch-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	infinipath <infinipath-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Latif, Faisal" <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Upinder Malhi <umalhi-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Trond Myklebust" <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	"Nikolova, Tatyana E" <tatyana.e.nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ilya Nelkenbaum <ilyan-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Shachar Raindel <raindel@mellan
To: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5523CF30.7000608-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc3lzZnMuYw0KPiBiL2RyaXZl
cnMvaW5maW5pYmFuZC9jb3JlL3N5c2ZzLmMNCj4gaW5kZXggY2JkMDM4My4uYWE1M2U0MCAxMDA2
NDQNCj4gLS0tIGEvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvc3lzZnMuYw0KPiArKysgYi9kcml2
ZXJzL2luZmluaWJhbmQvY29yZS9zeXNmcy5jDQo+IEBAIC0yNDgsMTQgKzI0OCwxMCBAQCBzdGF0
aWMgc3NpemVfdCBwaHlzX3N0YXRlX3Nob3coc3RydWN0IGliX3BvcnQgKnAsDQo+IHN0cnVjdCBw
b3J0X2F0dHJpYnV0ZSAqdW51c2VkLA0KPiAgc3RhdGljIHNzaXplX3QgbGlua19sYXllcl9zaG93
KHN0cnVjdCBpYl9wb3J0ICpwLCBzdHJ1Y3QgcG9ydF9hdHRyaWJ1dGUNCj4gKnVudXNlZCwNCj4g
IAkJCSAgICAgICBjaGFyICpidWYpDQo+ICB7DQo+IC0Jc3dpdGNoIChyZG1hX3BvcnRfZ2V0X2xp
bmtfbGF5ZXIocC0+aWJkZXYsIHAtPnBvcnRfbnVtKSkgew0KPiAtCWNhc2UgSUJfTElOS19MQVlF
Ul9JTkZJTklCQU5EOg0KPiArCWlmIChyZG1hX3RyYW5zcG9ydF9pYihwLT5pYmRldiwgcC0+cG9y
dF9udW0pKQ0KPiAgCQlyZXR1cm4gc3ByaW50ZihidWYsICIlc1xuIiwgIkluZmluaUJhbmQiKTsN
Cj4gLQljYXNlIElCX0xJTktfTEFZRVJfRVRIRVJORVQ6DQo+ICsJZWxzZQ0KPiAgCQlyZXR1cm4g
c3ByaW50ZihidWYsICIlc1xuIiwgIkV0aGVybmV0Iik7DQo+IC0JZGVmYXVsdDoNCj4gLQkJcmV0
dXJuIHNwcmludGYoYnVmLCAiJXNcbiIsICJVbmtub3duIik7DQo+IC0JfQ0KPiAgfQ0KPiANCj4g
IHN0YXRpYyBQT1JUX0FUVFJfUk8oc3RhdGUpOw0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9pbmZp
bmliYW5kL2NvcmUvdXZlcmJzX2NtZC5jDQo+IGIvZHJpdmVycy9pbmZpbmliYW5kL2NvcmUvdXZl
cmJzX2NtZC5jDQo+IGluZGV4IGE5ZjA0ODkuLjNlYjZlYjUgMTAwNjQ0DQo+IC0tLSBhL2RyaXZl
cnMvaW5maW5pYmFuZC9jb3JlL3V2ZXJic19jbWQuYw0KPiArKysgYi9kcml2ZXJzL2luZmluaWJh
bmQvY29yZS91dmVyYnNfY21kLmMNCj4gQEAgLTUxNSw4ICs1MTUsMTAgQEAgc3NpemVfdCBpYl91
dmVyYnNfcXVlcnlfcG9ydChzdHJ1Y3QgaWJfdXZlcmJzX2ZpbGUNCj4gKmZpbGUsDQo+ICAJcmVz
cC5hY3RpdmVfd2lkdGggICAgPSBhdHRyLmFjdGl2ZV93aWR0aDsNCj4gIAlyZXNwLmFjdGl2ZV9z
cGVlZCAgICA9IGF0dHIuYWN0aXZlX3NwZWVkOw0KPiAgCXJlc3AucGh5c19zdGF0ZSAgICAgID0g
YXR0ci5waHlzX3N0YXRlOw0KPiAtCXJlc3AubGlua19sYXllciAgICAgID0gcmRtYV9wb3J0X2dl
dF9saW5rX2xheWVyKGZpbGUtPmRldmljZS0NCj4gPmliX2RldiwNCj4gLQkJCQkJCQljbWQucG9y
dF9udW0pOw0KPiArCXJlc3AubGlua19sYXllciAgICAgID0gcmRtYV90cmFuc3BvcnRfaWIoZmls
ZS0+ZGV2aWNlLT5pYl9kZXYsDQo+ICsJCQkJCQkJY21kLnBvcnRfbnVtKSA/DQo+ICsJCQkgICAg
ICAgSUJfTElOS19MQVlFUl9JTkZJTklCQU5EIDoNCj4gKwkJCSAgICAgICBJQl9MSU5LX0xBWUVS
X0VUSEVSTkVUOw0KPiANCj4gIAlpZiAoY29weV90b191c2VyKCh2b2lkIF9fdXNlciAqKSAodW5z
aWduZWQgbG9uZykgY21kLnJlc3BvbnNlLA0KPiAgCQkJICZyZXNwLCBzaXplb2YgcmVzcCkpDQoN
CkJvdGggb2YgdGhlIGFib3ZlIGNoZWNrIHRoZSB0cmFuc3BvcnQgaW4gb3JkZXIgdG8gZGV0ZXJt
aW5lIHRoZSBsaW5rIGxheWVyLg0KDQpUaGVzZSB2YWx1ZXMgYXJlIGV4cG9zZWQgdG8gdXNlciBz
cGFjZS4gIERvZXMgYW55b25lIGtub3cgd2hhdCBsaW5rIGxheWVyIGlXYXJwIHJldHVybnMgdG8g
dXNlciBzcGFjZT8gDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
