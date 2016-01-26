From: Sjoerd Simons <sjoerd.simons-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
Subject: Re: [PATCH] brcmfmac: sdio: Increase the default timeouts a bit
Date: Tue, 26 Jan 2016 10:12:52 +0100
Message-ID: <1453799572.30130.51.camel@collabora.co.uk>
References: <1453718849-3508-1-git-send-email-sjoerd.simons@collabora.co.uk>
 <56A64114.3010400@gmail.com>
 <CAD=FV=X-ejMLnh30TofU7dKP5WwZaXcgLaQwFs__wo9wHsv53Q@mail.gmail.com>
 <56A68064.5020702@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 "Franky \(Zhenhui\) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
 "linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Adrian Hunter <adrian.hunter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
 Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, Doug Anderson
 <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,  Arend van Spriel <aspriel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <56A68064.5020702-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gTW9uLCAyMDE2LTAxLTI1IGF0IDIxOjA3ICswMTAwLCBBcmVuZCB2YW4gU3ByaWVsIHdyb3Rl
Ogo+IE9uIDI1LTEtMjAxNiAyMDoyMywgRG91ZyBBbmRlcnNvbiB3cm90ZToKPiA+IEtpbmRhIGN1
cmlvdXM6IGRvIHdlIGdldCBvbmUgb3IgdHdvIHJlYWxseSBzbG93IHJlc3BvbnNlcyBvbiBldmVy
eQo+ID4gYm9vdHVwLCBvciBqdXN0IHNvbWUgYm9vdHVwcz/CoMKgRG8gd2UgZXZlciBzdWNjZWVk
IGV2ZW4gd2l0aCBhIHNsb3cKPiA+IChsaWtlIDEuOCBvciAxLjkgc2Vjb25kcykgcmVzcG9uc2Us
IG9yIGlzIGl0IGFsd2F5cyBlaXRoZXIgImZhc3QiCj4gPiBvcgo+ID4gIjIuMSIgc2Vjb25kcz8K
PiAKPiBOb3cgdGhlc2UgYXJlIGludGVyZXN0aW5nIHF1ZXN0aW9ucyB0aGF0IEkgc2hvdWxkIGhh
dmUgc3BpbGxlZCBvdXQgaW4KPiB0aGUgZmlyc3QgcGxhY2UuIFRoYW5rcy4KCkkgd291bGQgbmVl
ZCB0byBnZXQgYSBtb3JlIGRhdGEgdG8gcmVhbGx5IGNvbmNsdXNpdmVseSBzYXksIGJ1dCB3aGF0
IGkKc2F3IGluIHRlc3RpbmcgdGh1c2ZhciB3YXM6CgoqIFRoZSBpc3N1ZSBvY2N1cnMgb24gX3Nv
bWVfIGJvb3RzCiogVGhlIGlzc3VlIHNlZW1zIHRvIGNvbWUgdXAgbW9yZSBvZnRlbiBvbiB3YXJt
IHJlYm9vdHMKKiBUaGUgbGlrZWx5aG9vZCBzZWVtZWQgdG8gY2hhbmdlIGRlcGVuZGluZyBvbiB0
aGUga2VybmVsCsKgIGNvbmZpZ3VyYXRpb24gKGlvdHcgd2hlbiB0aGUgaW5pdGlsaXNhdGlvbiBv
cmRlci90aW1pbmcgY2hhbmdlZD8pCiogRm9yY2luZyB0aGUgYnJjbWZtYWMgbW9kdWxlIHRvIGxv
YWQgbGF0ZXIgaW4gYm9vdCBzZWVtZWQgdG8gbWFrZSB0aGXCoArCoCBsaWtlbHlob29kIG9mIHRo
ZSBpc3N1ZSBzaG93aW5nIHVwIGxvd2VyLgoqIFRoZSBzYW1wbGVzIEkgaGF2ZSB3aXRoIHRyYWNl
cyBzaG93ZWQgZWl0aGVyIHF1aWNrIHJlc3BvbnNlcyBvbsKgCsKgIHN1Y2Nlc3Mgb3Igc2xvdyAi
Mi4xIiBzZWNvbmRzIHJlc3BvbnNlcyBvbiBmYWlsdXJlLgoKSSdsbCB0cnkgdG8gbWFrZSBzb21l
IHRpbWUgdG8gZ2V0IHNvbWUgc3RhdGlzdGljcyBvdmVyIGEgc2VyaWVzIG9mCmJvb3RzIHdydC4g
dGhlIHJlc3BvbnNlIHRpbWUocykgZm9yIGNvbnRyb2wgbWVzc2FnZXMgc28gd2UgY2FuIGdldCBh
CmJldHRlciBpZGVhIGhvdyBvZnRlbiB0aGlzIGhhcHBlbnMgYW5kIGl0cyBiZWhhdmlvdXIuCgoK
SSBndWVzcyBvbmUgb3RoZXIgdGhpbmcgdG8gbm90ZSBpcyB0aGF0IGJvdGggRG91ZyBhbmQgbXlz
ZWxmIHdlcmUKc2VlaW5nIHRoaXMgb24gUm9ja2NoaXAgUkszMjg4IGJhc2VkIGRldmljZXMuIEl0
IHdvdWxkIG9mY291cnNlIGJlCmludGVyZXN0aW5nIHRvIGtub3cgaWYgdGhpcyBoYXMgYmVlbiBz
ZWVuIG9uIG90aGVyIHR5cGVzIG9mIGRldmljZXMuLgoKLS3CoApTam9lcmQgU2ltb25zCkNvbGxh
Ym9yYSBMdGQuCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpMaW51eC1yb2NrY2hpcCBtYWlsaW5nIGxpc3QKTGludXgtcm9ja2NoaXBAbGlzdHMuaW5mcmFk
ZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4
LXJvY2tjaGlwCg==
