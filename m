From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 09:18:39 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB303D23ABD@HASMSX103.ger.corp.intel.com>
References: <1342235583.20131211182804@eikelenboom.it>
	<CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
	<871324710.20131211191104@eikelenboom.it>
	<CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
	<1937118387.20131216122200@eikelenboom.it>	<52AEE60B.6030509@broadcom.com>
	<19210260274.20131216135644@eikelenboom.it>
	<CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com>
	<1534126119.20131217104548@eikelenboom.it>
	<387552477.20131217213319@eikelenboom.it>
	<20131217212709.GB5624@decadent.org.uk>
	<1254825772.20131217224914@eikelenboom.it>
 <CA+55aFxQg6=MAWEkEGz64Hz8OawvPyX=fpBOjY8cGBL5XgB9WQ@mail.gmail.com>
 <52B167F6.5060209@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org" <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Avinash Patil <avinashapatil-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Sander Eikelenboom <linux-6SM94LqRVpn6gRhOQ7JHfg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52B167F6.5060209-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiANCj4gT24gMTIvMTcvMjAxMyAxMTowNiBQTSwgTGludXMgVG9ydmFsZHMgd3JvdGU6DQo+ID4g
V2UgaGF2ZSBsaXRlcmFsbHkgaGFkIHRoaXMgKmV4YWN0KiBzYW1lIGlzc3VlIHdpdGggZmlybXdh
cmUgbG9hZGluZy4NCj4gPiBOZXR3b3JrIGRyaXZlcnMgc2hvdWxkbid0IHRyeSB0byBsb2FkIGZp
cm13YXJlIGF0IG1vZHVsZSBsb2FkIHRpbWUuDQo+ID4gU2FtZSBkZWFsLg0KPiANCj4gSXQgaXMg
a2luZCBvZiBhIGNoaWNrZW4gYW5kIGVnZyBwcm9ibGVtIGZvciAod2lyZWxlc3MpIG5ldHdvcmtp
bmcgZHJpdmVycy4gVG8NCj4gZ2V0IElGRl9VUCBmcm9tIHRoZSBuZXR3b3JrIGxheWVyIHlvdSBo
YXZlIHRvIHJlZ2lzdGVyIGEgbmV0ZGV2aWNlLiBGb3INCj4gd2lyZWxlc3MgZHJpdmVycyB0aGlz
IG1lYW5zIHlvdSBoYXZlIHRvIHJlZ2lzdGVyIGEgd2lwaHkgZGV2aWNlIHdpdGggY2ZnODAyMTEN
Cj4gd2hpY2ggZmxhZ3MgY2FwYWJpbGl0aWVzIGFuZCBvcHRpb25hbGx5IGFyZSBjdXN0b20gcmVn
dWxhdG9yeSBkb21haW4uIFRoYXQNCj4gaW5mb3JtYXRpb24gZGVwZW5kcyBvbiB0aGUgZGV2aWNl
IGFuZCBmaXJtd2FyZSB1c2VkLiBBbmQgdGhlcmUgd2UgaGF2ZSBhDQo+IGZ1bGwgY2lyY2xlLg0K
PiANCg0KVG8gc29sdmUgdGhpcyAtIGl3bHdpZmkgdXNlcyByZXF1ZXN0X2Zpcm13YXJlX25vd2Fp
dC4gSXRzIGRvYyByZWFkczoNCg0KIkFzeW5jaHJvbm91cyB2YXJpYW50IG9mIHJlcXVlc3RfZmly
bXdhcmUgZm9yIHVzZXIgY29udGV4dHM6IC0gc2xlZXAgZm9yIGFzIHNtYWxsIHBlcmlvZHMgYXMg
cG9zc2libGUgc2luY2UgaXQgbWF5IGluY3JlYXNlIGtlcm5lbCBib290IHRpbWUgb2YgYnVpbHQt
aW4gZGV2aWNlIGRyaXZlcnMgcmVxdWVzdGluZyBmaXJtd2FyZSBpbiB0aGVpciAtPnByb2JlIG1l
dGhvZHMsIGlmIGdmcCBpcyBHRlBfS0VSTkVMLiINCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
