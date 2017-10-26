From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: v4.14-rc3/arm64 DABT exception in atomic_inc() / __skb_clone()
Date: Thu, 26 Oct 2017 15:24:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00A59B0@AcuExch.aculab.com>
References: <EAA60182-6F08-412E-8F8B-FD4B0309A858@gmail.com>
 <20171020111408.edj24tztxdptte5r@lakrids.cambridge.arm.com>
 <960D71EC-C1E9-4898-ACBE-543FC09483FF@gmail.com>
 <CACT4Y+bjzzCv3LSxK12C1xB8GfR3UYCrX_5phRYJ8fpxh9vcvQ@mail.gmail.com>
 <CAF=yD-K76TMjHiYRTRAnxM-x4LBcUDY+27WX477HW6kG=L_aZw@mail.gmail.com>
 <D2AD6D5B-3A05-48E7-A999-DECAB18A4649@gmail.com>
 <CAF=yD-JFjjA=2T7HermH2GygfHinyW+ZC5v+Di7M4V_Fg5paHg@mail.gmail.com>
 <CAF=yD-Lw2E7T12sA-dgMK5kn=L0TLGQE+v68s1X8HMHLq9hGBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Mark Rutland <mark.rutland@arm.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        "David Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: 'Willem de Bruijn' <willemdebruijn.kernel@gmail.com>,
        Wei Wei <dotweiba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:53488 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932617AbdJZPYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:24:21 -0400
In-Reply-To: <CAF=yD-Lw2E7T12sA-dgMK5kn=L0TLGQE+v68s1X8HMHLq9hGBA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogV2lsbGVtIGRlIEJydWlqbg0KPiBTZW50OiAyNSBPY3RvYmVyIDIwMTcgMTk6NTANCi4u
Lg0KPiBGcm9tIHNrYi0+ZGV2IGFuZCBuZXRkZXZfcHJpdiwgdGhlIHR1biBkZXZpY2UgaGFzIGZs
YWdzIDB4MTAwMiA9PQ0KPiBJRkZfVEFQIHwgSUZGX05PX1BJLiBUaGlzIGtlcm5lbCBwcmVjZWRl
cyB0aGUgcmVjZW50IHN1cHBvcnQgZm9yDQo+IElGRl9OQVBJIGFuZCBJRkZfTkFQSV9GUkFHUy4g
VGhlIGFsbG9jYXRpb24gbW9zdCBsaWtlbHkgaGFwcGVuZWQNCj4gaW4gdHVuX2J1aWxkX3NrYiBm
cm9tIGN1cnJlbnQtPnRhc2tfZnJhZy4gSXQgd291bGQgYmUgYSBwcmV2aW91cw0KPiBhbGxvY2F0
aW9uIHRoYXQgbGVmdCBhbGxvY19mcmFnLT5vZmZzZXQgdW5hbGlnbmVkLiBCdXQgcGVyaGFwcyB0
aGlzIGNvZGUNCj4gbmVlZHMgdG8gcGVyZm9ybSBhbGlnbm1lbnQgYmVmb3JlIHNldHRpbmcgc2ti
LT5oZWFkLg0KPg0KPiBBdCBsZWFzdCBvbiBwbGF0Zm9ybXMgd2hlcmUgYXRvbWljIG9uIGRhdGFy
ZWYgbXVzdCBiZSBhbGlnbmVkLg0KDQpJc24ndCB0aGF0IHRydWUgb2YgYWxtb3N0IGV2ZXJ5dGhp
bmc/DQpJJ20gbm90IGV2ZW4gc3VyZSB4ODYgYWx3YXlzIChldmVyPykgbWFuYWdlcyBsb2NrZWQg
Y3ljbGVzIG9uDQptaXNhbGlnbmVkIGFkZHJlc3Nlcy4NCg0KCURhdmlkDQoNCg==
