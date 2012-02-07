From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] NFS: make nfs_client_list per net ns
Date: Tue, 7 Feb 2012 15:34:48 +0000
Message-ID: <1328628888.4124.16.camel@lade.trondhjem.org>
References: <20120123172605.29637.15682.stgit@localhost6.localdomain6>
	 <4F3143F4.3010502@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org" <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Schumaker, Bryan" <Bryan.Schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F3143F4.3010502-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Content-ID: <3AA830B78768D54E87D975703D2A8E82-oP88Kt8RkgzdA/Lu/QRl1Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCAyMDEyLTAyLTA3IGF0IDEwOjMyIC0wNTAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IEkgZml4ZWQgdXAgbXkgYmlzZWN0IGFuZCBpZGVudGlmaWVkIHRoaXMgcGF0Y2ggaW5zdGVh
ZC4gIFRoZSBwcm9ibGVtIEknbSBzZWVpbmcgaXM6DQo+IA0KPiAgIENDIFtNXSAgZnMvbmZzL2Rl
bGVnYXRpb24ubw0KPiAgIENDIFtNXSAgZnMvbmZzL2lkbWFwLm8NCj4gZnMvbmZzL2lkbWFwLmM6
IEluIGZ1bmN0aW9uICdycGNfcGlwZWZzX2V2ZW50JzoNCj4gZnMvbmZzL2lkbWFwLmM6NTM1Ojk6
IGVycm9yOiBpbXBsaWNpdCBkZWNsYXJhdGlvbiBvZiBmdW5jdGlvbiAnbmV0X2dlbmVyaWMnIFst
V2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXQ0KPiBmcy9uZnMvaWRtYXAuYzo1
MzU6NTA6IGVycm9yOiAnbmZzX25ldF9pZCcgdW5kZWNsYXJlZCAoZmlyc3QgdXNlIGluIHRoaXMg
ZnVuY3Rpb24pDQo+IGZzL25mcy9pZG1hcC5jOjUzNTo1MDogbm90ZTogZWFjaCB1bmRlY2xhcmVk
IGlkZW50aWZpZXIgaXMgcmVwb3J0ZWQgb25seSBvbmNlIGZvciBlYWNoIGZ1bmN0aW9uIGl0IGFw
cGVhcnMgaW4NCj4gZnMvbmZzL2lkbWFwLmM6NTQwOjgyOiBlcnJvcjogZGVyZWZlcmVuY2luZyBw
b2ludGVyIHRvIGluY29tcGxldGUgdHlwZQ0KPiBmcy9uZnMvaWRtYXAuYzo1NDA6MjI0OiBlcnJv
cjogZGVyZWZlcmVuY2luZyBwb2ludGVyIHRvIGluY29tcGxldGUgdHlwZQ0KPiBjYzE6IHNvbWUg
d2FybmluZ3MgYmVpbmcgdHJlYXRlZCBhcyBlcnJvcnMNCj4gDQo+IG1ha2VbMl06ICoqKiBbZnMv
bmZzL2lkbWFwLm9dIEVycm9yIDENCj4gbWFrZVsxXTogKioqIFtmcy9uZnNdIEVycm9yIDINCj4g
bWFrZTogKioqIFtmc10gRXJyb3IgMg0KPiANCj4gSSB0aGluayB5b3UgbmVlZCB0byBhZGQ6ICNp
bmNsdWRlICJuZXRucy5oIiB0byBpZG1hcC5jLg0KPiANCj4gLSBCcnlhbg0KDQpUaGF0IHNob3Vs
ZCBhbHJlYWR5IGJlIHRoZXJlIGluIHRoZSAnZGV2ZWwnIGJyYW5jaC4gU2VlIGNvbW1pdA0KMTcz
NDdkMDNjMDA4ZTJmNTA0YzMzYmI0OTA1Y2RhZDBhYmMwMTMxOS4NCg0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xl
YnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
