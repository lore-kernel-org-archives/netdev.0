From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Thu, 17 Aug 2017 09:15:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0058EDB@AcuExch.aculab.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca>
 <1502702846.8411.25.camel@redhat.com> <1846443.VTclhqQinN@ring00>
 <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com>
 <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com>
 <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
 <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
 <1502875722.3548.11.camel@redhat.com>
 <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
 <1502914822.2796.6.camel@redhat.com>
 <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: 'Willem de Bruijn' <willemdebruijn.kernel@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:57020 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdHQJPW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 05:15:22 -0400
In-Reply-To: <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogV2lsbGVtIGRlIEJydWlqbg0KPiBTZW50OiAxNyBBdWd1c3QgMjAxNyAwMDoyNw0KPiBB
Y3R1YWxseSwgaXQgaXMgc2FmZSBldmVuIHdpdGhvdXQgdGhlIGNoZWNrLiBPdmVyZmxvdyBvZiB0
aGUgc2lnbmVkIGludGVnZXINCj4gaXMgYmVuaWduIGhlcmUuDQoNCklJUkMgdGhlIEMgbGFuZ3Vh
Z2Ugc3RhdGVzIHRoYXQgJ3NpZ25lZCBpbnRlZ2VyIG92ZXJmbG93JyBpcyB1bmRlZmluZWQuDQpT
byAnTUFYSU5UICsgMScgZG9lc24ndCBoYXZlIHRvIGVxdWFsICctTUFYSU5UIC0gMScgKGFzIG9u
ZSB3b3VsZA0KZXhwZWN0IG9uIGEgMidzIGNvbXBsaW1lbnQgc3lzdGVtKS4NCg0KV2hpbGUgdGhl
IGxpbnV4IGtlcm5lbCBwcm9iYWJseSB3b24ndCBydW4gb24gc3lzdGVtcyB3aGVyZSB0aGlzIGlz
bid0IHRydWUNCihlZyB3aGVyZSBzaWduZWQgYXJpdGhtZXRpYyBzYXR1cmF0ZXMpIGdjYyB3aWxs
IGFzc3VtZSBpdCBjYW4ndCBoYXBwZW4NCmFuZCBvcHRpbWlzZSBjb2RlIHdpdGggdGhhdCBhc3N1
bXB0aW9uLg0KDQpUaGlzIG1heSBub3QgbWF0dGVyIGhlcmUgLi4uDQoNCglEYXZpZA0KDQo=
