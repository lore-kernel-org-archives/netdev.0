From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: Make phy_ethtool_ksettings_get return void
Date: Mon, 12 Jun 2017 10:59:05 -0400 (EDT)
Message-ID: <20170612.105905.1031273319008486521.davem@davemloft.net>
References: <20170612141508.29229-1-yuval.shaia@oracle.com>
        <20170612.102525.1159274040679939960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: michael.chan@broadcom.com, f.fainelli@gmail.com,
        siva.kallam@broadcom.com, prashant@broadcom.com,
        madalin.bucur@nxp.com, leoli@freescale.com,
        sebastian.hesselbarth@gmail.com,
        sergei.shtylyov@cogentembedded.com, grygorii.strashko@ti.com,
        w-kwok2@ti.com, m-karicheri2@ti.com, andrew@lunn.ch,
        woojung.huh@microchip.com, UNGLinuxDriver@microchip.com,
        vivien.didelot@savoirfairelinux.com, arnd@arndb.de,
        tremyfr@gmail.com, jarod@redhat.com, horms+renesas@verge.net.au,
        kazuya.mizuguchi.ks@renesas.com, dan.carpenter@oracle.com,
        niklas.soderlund+renesas@ragnatech.se, johan@kernel.org,
        masaru.nagai.vx@renesas.com, geert+renesas@glider.be,
        laurent.pinchart@ideasonboard.com, chris.brandt@renesas.com,
        ivan.khoronzhuk@linaro.org, mugunthanvnm@ti.com,
        netdev@vger.kernel.org, linux-arm-kernel
To: yuval.shaia@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751981AbdFLO7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 10:59:13 -0400
In-Reply-To: <20170612.102525.1159274040679939960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogTW9uLCAxMiBK
dW4gMjAxNyAxMDoyNToyNSAtMDQwMCAoRURUKQ0KDQo+IEZyb206IFl1dmFsIFNoYWlhIDx5dXZh
bC5zaGFpYUBvcmFjbGUuY29tPg0KPiBEYXRlOiBNb24sIDEyIEp1biAyMDE3IDE3OjE1OjA4ICsw
MzAwDQo+IA0KPj4gTWFrZSByZXR1cm4gdmFsdWUgdm9pZCBzaW5jZSBmdW5jdGlvbiBuZXZlciBy
ZXR1cm4gbWVhbmluZ2Z1bGwgdmFsdWUNCj4+IA0KPj4gU2lnbmVkLW9mZi1ieTogWXV2YWwgU2hh
aWEgPHl1dmFsLnNoYWlhQG9yYWNsZS5jb20+DQo+PiBBY2tlZC1ieTogU2VyZ2VpIFNodHlseW92
IDxzZXJnZWkuc2h0eWx5b3ZAY29nZW50ZW1iZWRkZWQuY29tPg0KPj4gLS0tDQo+PiB2MCAtPnYx
Og0KPj4gCSogVGhlc2UgZmlsZXMgd2VyZSBtaXNzaW5nIGluIHYwDQo+PiAJCSogZHJpdmVycy9u
ZXQvZXRoZXJuZXQvcmVuZXNhcy9yYXZiX21haW4uYw0KPj4gCQkqIGRyaXZlcnMvbmV0L2V0aGVy
bmV0L3JlbmVzYXMvc2hfZXRoLmMNCj4+IAkJKiBkcml2ZXJzL25ldC9ldGhlcm5ldC90aS9uZXRj
cF9ldGhzcy5jDQo+PiAJKiBBZGQgQWNrZWQtYnk6IFNlcmdlaSBTaHR5bHlvdg0KPj4gdjEgLT4g
djI6DQo+PiAJKiBBZGp1c3QgdG8gbmV0LW5leHQgdHJlZQ0KPiANCj4gQXBwbGllZCwgdGhhbmsg
eW91Lg0KDQpSZXZlcnRlZCwgcGxlYXNlIHRlc3QgeW91ciBidWlsZCBwcm9wZXJseToNCg0KZHJp
dmVycy9uZXQvZXRoZXJuZXQvYXBtL3hnZW5lL3hnZW5lX2VuZXRfZXRodG9vbC5jOiBJbiBmdW5j
dGlvbiCheGdlbmVfZ2V0X2xpbmtfa3NldHRpbmdzojoNCmRyaXZlcnMvbmV0L2V0aGVybmV0L2Fw
bS94Z2VuZS94Z2VuZV9lbmV0X2V0aHRvb2wuYzoxMzQ6MTA6IGVycm9yOiB2b2lkIHZhbHVlIG5v
dCBpZ25vcmVkIGFzIGl0IG91Z2h0IHRvIGJlDQogICByZXR1cm4gcGh5X2V0aHRvb2xfa3NldHRp
bmdzX2dldChwaHlkZXYsIGNtZCk7DQogICAgICAgICAgXg0KZHJpdmVycy9uZXQvZXRoZXJuZXQv
YXBtL3hnZW5lL3hnZW5lX2VuZXRfZXRodG9vbC5jOjE0MDoxMTogZXJyb3I6IHZvaWQgdmFsdWUg
bm90IGlnbm9yZWQgYXMgaXQgb3VnaHQgdG8gYmUNCiAgICByZXR1cm4gcGh5X2V0aHRvb2xfa3Nl
dHRpbmdzX2dldChwaHlkZXYsIGNtZCk7DQogICAgICAgICAgIF4NCnNjcmlwdHMvTWFrZWZpbGUu
YnVpbGQ6MzAyOiByZWNpcGUgZm9yIHRhcmdldCAnZHJpdmVycy9uZXQvZXRoZXJuZXQvYXBtL3hn
ZW5lL3hnZW5lX2VuZXRfZXRodG9vbC5vJyBmYWlsZWQNCg==
