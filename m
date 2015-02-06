From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Throughput regression with `tcp: refine TSO autosizing`
Date: Fri, 6 Feb 2015 14:31:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CADF4EC@AcuExch.aculab.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	 <1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	 <1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	 <1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	 <1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	 <1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	 <1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	 <1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	 <1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	 <1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	 <1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
 <1423231841.31870.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"eyalpe@dev.mellanox.co.il" <eyalpe@dev.mellanox.co.il>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:60273 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990AbbBFOb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 09:31:59 -0500
In-Reply-To: <1423231841.31870.133.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIEZyaSwgMjAxNS0wMi0wNiBhdCAwNTo1MyAtMDgwMCwg
RXJpYyBEdW1hemV0IHdyb3RlOg0KPiANCj4gDQo+ID4gd2lmaSBjb3VsZCBldmVudHVhbGx5IGRv
IHRoYXQsIHByb3ZpZGluZyBpbiBza2ItPnR4X2NvbXBsZXRpb25fZGVsYXlfdXMNCj4gPiB0aGUg
dGltZSBzcGVudCBpbiB3aWZpIGRyaXZlci4NCj4gPg0KPiA+IFRoaXMgd2F5LCB3ZSB3b3VsZCBo
YXZlIG5vIHBlbmFsdHkgZm9yIG5ldHdvcmsgZGV2aWNlcyBkb2luZyBub3JtYWwgc2tiDQo+ID4g
b3JwaGFuaW5nIChsb29wYmFjayBpbnRlcmZhY2UsIGV0aGVybmV0LCAuLi4pDQo+IA0KPiBBbm90
aGVyIHdheSB3b3VsZCBiZSB0aGF0IHdpZmkgZG9lcyBhbiBhdXRvbWF0aWMgb3JwaGFuaW5nIGFm
dGVyIDEgb3INCj4gMm1zLg0KDQpDb3VsZG4ndCB5b3UgZG8gYnl0ZSBjb3VudGluZz8NClNvIG9y
cGhhbiBlbm91Z2ggcGFja2V0cyB0byBrZWVwIGEgZmV3IG1zIG9mIHR4IHRyYWZmaWMgKGF0IHRo
ZSBjdXJyZW50DQp0eCByYXRlKSBvcnBoYW5lZC4NCllvdSBtaWdodCBuZWVkIHRvIGdpdmUgdGhl
IGhhcmR3YXJlIGJvdGggb3JwaGFuZWQgYW5kIG5vbi1vcnBoYW5lZCAocGFyZW50ZWQ/KQ0KcGFj
a2V0cyBhbmQgb3JwaGFuIHNvbWUgd2hlbiB5b3UgZ2V0IGEgdHggY29tcGxldGUgZm9yIGFuIG9y
cGhhbmVkIHBhY2tldC4NCg0KCURhdmlkDQoNCg==
