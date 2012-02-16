From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH] SUNRPC: connect local transports synchronously
Date: Thu, 16 Feb 2012 15:13:53 +0000
Message-ID: <1329405232.4279.4.camel@lade.trondhjem.org>
References: <20120216150507.19081.28659.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120216150507.19081.28659.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Content-Language: en-US
Content-ID: <C889075737E6264D975E0FAE3246B671-oP88Kt8RkgzdA/Lu/QRl1Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gVGh1LCAyMDEyLTAyLTE2IGF0IDE5OjA2ICswNDAwLCBTdGFuaXNsYXYgS2luc2J1cnNreSB3
cm90ZToNCj4gTG9jYWwgdHJhbnBvcnRzIHVzZXMgVU5JWCBzb2NrZXRzIGFuZCBjb25uZWN0aW5n
IG9mIHRoZXNlIHNvY2tldHMgaXMgZG9uZSBpbg0KPiBjb250ZXh0IG9mIGZpbGUgc3lzdGVtIG5h
bWVzcGFjZSAoaS5lLiB0YXNrIGZpbGUgc3lzdGVtIHJvb3QpLg0KPiBDdXJyZW5seSwgYWxsIHNv
Y2tldHMgY29ubmVjdCBvcGVyYXRpb25zIGFyZSBwZXJmb3JtZWQgYnkgcnBjaW9kIHdvcmsgcXVl
dWUsDQo+IHdoaWNoIGFjdHVhbGx5IG1lYW5zLCB0aGF0IGFueSBzZXJ2aWNlIHdpbGwgYmUgcmVn
aXN0ZXJlZCBpbiB0aGUgc2FtZSBycGNiaW5kDQo+IGluc3RhbmNlIHJlZ2FyZGxlc3MgdG8gcHJv
Y2VzcyBmaWxlIHN5c3RlbSByb290Lg0KPiBUaGlzIGlzIG5vdCBjb250YWluZXJzLCB3aGljaCB1
c3VhbGx5IGhhdmUgaXQncyBvd24gbmVzdGVkIHJvb3QuIFRoZXJlIGFyZSAyDQo+IGFwcHJvYWNo
ZXMsIGhvdyB0byBzb2x2ZSB0aGUgcHJvYmxlbS4gRmlyc3Qgb25lIGlzIHRvIHN0b3JlIHByb3Bl
ciByb290IGluDQo+IHRyYW5wb3J0IGFuZCBzd2l0Y2ggdG8gaXQgaW4gcnBjaW9kIHdvcmtxdWV1
ZSBmdW5jdGlvbiBmb3IgY29ubmVjdCBvcGVyYXRpb25zLg0KPiBCdXQgdGhpcyBsb29rcyB1Z2x5
LiBUaGUgc2Vjb25kIG9uZSBpcyB0byBjb25uZWN0IHRvIHVuaXggc29ja2V0cw0KPiBzeW5jaHJv
bm91c2x5LiBUaGlzIGFwdGNoIGltcGxlbWVudHMgdGhlIGxhc3Qgb25lLg0KDQpUaGF0IGFwcHJv
YWNoIGNhbiBmYWxsIGFmb3VsIG9mIHRoZSBzZWxpbnV4IHJlc3RyaWN0aW9ucyBvbiB0aGUgcHJv
Y2Vzcw0KY29udGV4dC4gUHJvY2Vzc2VzIHRoYXQgYXJlIGFsbG93ZWQgdG8gd3JpdGUgZGF0YSwg
bWF5IG5vdCBiZSBhbGxvd2VkIHRvDQpjcmVhdGUgc29ja2V0cyBvciBjYWxsIGNvbm5lY3QoKS4g
VGhhdCBpcyB0aGUgbWFpbiByZWFzb24gZm9yIGRvaW5nIGl0DQppbiB0aGUgcnBjaW9kIGNvbnRl
eHQsIHdoaWNoIGlzIGEgY2xlYW4ga2VybmVsIHByb2Nlc3MgY29udGV4dC4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25k
Lk15a2xlYnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
