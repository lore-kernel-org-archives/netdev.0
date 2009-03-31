From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Tue, 31 Mar 2009 16:16:58 +0800
Message-ID: <2a27d3730903310116r4d8602b8y41e466801bbb8d3e@mail.gmail.com>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
	<OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
	<49CCD3E8.9040007@freescale.com>
	<OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se>
	<49D0FFBB.7000009@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linuxppc-dev@ozlabs.org, Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49D0FFBB.7000009@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

T24gVHVlLCBNYXIgMzEsIDIwMDkgYXQgMToyMiBBTSwgU2NvdHQgV29vZCA8c2NvdHR3b29kQGZy
ZWVzY2FsZS5jb20+IHdyb3RlOgo+IEpvYWtpbSBUamVybmx1bmQgd3JvdGU6Cj4+Cj4+IGdpYW5m
YXIgZG9lcyBub3Qgc2VlbSB0byB1c2UgaW5fL291dF8gZnVuY3Rpb25zIGZvciB0aGUgQkRzLiBX
b3JrcyBqdXN0Cj4+IGZpbmUgdGhhdCB0b28gaXQgc2VlbXMuCj4KPiBJdCBkb2VzIG5vdyB0aGF0
IGl0IGhhcyBleHBsaWNpdCBiYXJyaWVycyBpbiBhIGZldyBwbGFjZXMuIMKgQmVmb3JlIHRoZXkg
d2VyZQo+IGFkZGVkLCBpdCB3b3VsZCBzb21ldGltZXMgZmFpbCB1bmRlciBsb2FkLiDCoFRoYXQg
d2FzIGR1ZSB0byBhIGNvbXBpbGVyCj4gcmVvcmRlcmluZywgYnV0IENQVSByZW9yZGVyaW5nIHdh
cyBwb3NzaWJsZSBhcyB3ZWxsLgoKSSBub3RpY2VkIHRoYXQgaW4gZ2lhbmZhciB0aGVzZSBtZW1v
cnkgYWNjZXNzIGlzIG5vdCBwcm90ZWN0ZWQgYnkKInZvbGF0aWxlIi4gIENhbiB0aGlzIGJlIHRo
ZSByZWFzb24gd2h5IHRoZSBjb21waWxlciBkaWQgc29tZSB1bndhbnRlZApvcHRpbWl6YXRpb24/
CgotIExlbwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpM
aW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBvemxhYnMub3JnCmh0dHBzOi8v
b3psYWJzLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==
