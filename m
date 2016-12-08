From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Intel-wired-lan] [RFC PATCH] i40e: enable PCIe relax ordering
 for SPARC
Date: Thu, 8 Dec 2016 10:43:15 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02382BD@AcuExch.aculab.com>
References: <1480957627-16825-1-git-send-email-tushar.n.dave@oracle.com>
 <CAKgT0UcyRSub0NCi7oHX2Vf+N4vQxzwdWmcc+V+jOX_J=RYgfg@mail.gmail.com>
 <ec140d5d-3eec-5fc6-6417-11bacc55b807@oracle.com>
 <CAKgT0UfTP+BrvDBzUJAVr9-DRCKgM7T3aS=LgRic8UZz8x82eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        tndave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:64111 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbcLHKn2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 05:43:28 -0500
In-Reply-To: <CAKgT0UfTP+BrvDBzUJAVr9-DRCKgM7T3aS=LgRic8UZz8x82eg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDA2IERlY2VtYmVyIDIwMTYgMTc6MTANCi4u
Lg0KPiBJIHdhcyB0aGlua2luZyBhYm91dCBpdCBhbmQgSSByZWFsaXplZCB3ZSBjYW4gcHJvYmFi
bHkgc2ltcGxpZnkgdGhpcw0KPiBldmVuIGZ1cnRoZXIuICBJbiB0aGUgY2FzZSBvZiBtb3N0IG90
aGVyIGFyY2hpdGVjdHVyZXMgdGhlDQo+IERNQV9BVFRSX1dFQUtfT1JERVJJTkcgaGFzIG5vIGVm
ZmVjdCBhbnl3YXkuICBTbyBmcm9tIHdoYXQgSSBjYW4gdGVsbA0KPiB0aGVyZSBpcyBwcm9iYWJs
eSBubyByZWFzb24gbm90IHRvIGp1c3QgYWx3YXlzIHBhc3MgdGhhdCBhdHRyaWJ1dGUNCj4gd2l0
aCB0aGUgRE1BIG1hcHBpbmdzLiAgRnJvbSB3aGF0IEkgY2FuIHRlbGwgdGhlIG9ubHkgb3RoZXIN
Cj4gYXJjaGl0ZWN0dXJlIHRoYXQgdXNlcyB0aGlzIGlzIHRoZSBQb3dlclBDIENlbGwgYXJjaGl0
ZWN0dXJlLg0KDQpBbmQgSSBzaG91bGQgaGF2ZSByZWFkIGFsbCB0aGUgdGhyZWFkIDotKA0KDQo+
IEFsc28gSSB3YXMgd29uZGVyaW5nIGlmIHlvdSBhY3R1YWxseSBuZWVkZWQgdG8gZW5hYmxlIHRo
aXMgYXR0cmlidXRlDQo+IGZvciBib3RoIFJ4IGFuZCBUeCBidWZmZXJzIG9yIGp1c3QgUnggYnVm
ZmVycz8gIFRoZSBwYXRjaCB0aGF0IGVuYWJsZWQNCj4gRE1BX0FUVFJfV0VBS19PUkRFUklORyBm
b3IgU3BhcmM2NCBzZWVtcyB0byBjYWxsIG91dCB3cml0ZXMsIGJ1dCBJDQo+IGRpZG4ndCBzZWUg
YW55dGhpbmcgYWJvdXQgcmVhZHMuICBJJ20ganVzdCB3b25kZXJpbmcgaWYgY2hhbmdpbmcgdGhl
DQo+IGNvZGUgZm9yIFR4IGhhcyBhbnkgZWZmZWN0PyAgSWYgbm90IHlvdSBjb3VsZCBwcm9iYWJs
eSBkcm9wIHRob3NlDQo+IGNoYW5nZXMgYW5kIGp1c3QgZm9jdXMgb24gUnguDQoNCidXZWFrIG9y
ZGVyaW5nJyBvbmx5IGFwcGxpZXMgdG8gUENJZSByZWFkIHRyYW5zZmVycywgc28gY2FuIG9ubHkg
aGF2ZQ0KYW4gZWZmZWN0IG9uIGRlc2NyaXB0b3IgcmVhZHMgYW5kIHRyYW5zbWl0IGJ1ZmZlciBy
ZWFkcy4NCg0KQmFzaWNhbGx5IFBDSWUgaXMgYSBjb21tcyBwcm90b2NvbCBhbmQgYW4gZW5kcG9p
bnQgKG9yIHRoZSBob3N0KSBjYW4NCmhhdmUgbXVsdGlwbGUgb3V0c3RhbmRpbmcgcmVhZCByZXF1
ZXN0cyAoZWFjaCBvZiB3aGljaCBtaWdodCBnZW5lcmF0ZQ0KbXVsdGlwbGUgcmVzcG9uc2UgbWVz
c2FnZXMuDQpUaGUgcmVzcG9uc2VzIGZvciBlYWNoIHJlcXVlc3QgbXVzdCBhcnJpdmUgaW4gb3Jk
ZXIsIGJ1dCByZXNwb25zZXMgZm9yDQpkaWZmZXJlbnQgcmVxdWVzdHMgY2FuIGJlIGludGVybGVh
dmVkLg0KU2V0dGluZyAnbm90IHdlYWsgb3JkZXJpbmcnIGxldHMgdGhlIGhvc3QgaW50ZXJ3b3Jr
IHdpdGggYnJva2VuIGVuZHBvaW50cy4NCihPciwgbGlrZSB3ZSBkaWQsIHlvdSBmaXggdGhlIGZw
Z2EncyBQQ0llIGltcGxlbWVudGF0aW9uLikNCg0KSW4gdGhpcyBjYXNlIHlvdSBuZWVkIHRoZSBy
ZWFkcyBvZiBib3RoIHRyYW5zbWl0IGFuZCByZWNlaXZlIHJpbmdzIHRvDQonb3ZlcnRha2UnIHJl
YWRzIG9mIHRyYW5zbWl0IGRhdGEuDQoNCkknbSBub3QgYXQgYWxsIGNsZWFyIGhvdyB0aGlzICdm
bGFnJyBjYW4gYmUgc2V0IG9uIGRtYV9tYXAoKS4NCkl0IGlzIGEgcHJvcGVydHkgb2YgdGhlIFBD
SWUgc3Vic3lzdGVtLg0KDQoJRGF2aWQNCg0KDQo=
