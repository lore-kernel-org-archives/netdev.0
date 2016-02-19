From: Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Subject: Re: [PATCH RESEND] ethernet:arc: Move arc_emac_tx_clean() into
 arc_emac_tx() and disable tx interrut
Date: Fri, 19 Feb 2016 21:59:27 +0800
Message-ID: <56C71FBF.1070303@rock-chips.com>
References: <BLU436-SMTP169C63F9B677DE7B0A77CF38FA00@phx.gbl>
 <85B47C95-B524-4A25-90C7-95AE614AB3A2@mniewoehner.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
Content-Transfer-Encoding: base64
Cc: caesar.upstream-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org,
 zhengxing <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Shuyu Wei <sy.w-1ViLX0X+lBJBDgjK7y7TUQ@public.gmane.org>,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Michael Niewoehner <linux-zzFNMPX9jIaDjmgdnaGrkw@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <85B47C95-B524-4A25-90C7-95AE614AB3A2-zzFNMPX9jIaDjmgdnaGrkw@public.gmane.org>
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

T24gMjAxNuW5tDAy5pyIMTnml6UgMTk6MTMsIE1pY2hhZWwgTmlld29laG5lciB3cm90ZToKPiBB
bSAxOS4wMi4yMDE2IHVtIDA3OjU5IHNjaHJpZWIgU2h1eXUgV2VpPHN5LndAb3V0bG9vay5jb20+
Ogo+Cj4+IERvaW5nIHR4X2NsZWFuKCkgaW5zaWRlIHBvbGwoKSBtYXkgc2NyYW1ibGUgdGhlIHR4
IHJpbmcgYnVmZmVyIGlmCj4+IHR4KCkgaXMgcnVubmluZy4gVGhpcyB3aWxsIGNhdXNlIHR4IHRv
IHN0b3Agd29ya2luZywgd2hpY2ggY2FuIGJlCj4+IHJlcHJvZHVjZWQgYnkgc2ltdWx0YW5lb3Vz
bHkgZG93bmxvYWRpbmcgdHdvIGxhcmdlIGZpbGVzIGF0IGhpZ2ggc3BlZWQuCj4+Cj4+IE1vdmlu
ZyB0eF9jbGVhbigpIGludG8gdHgoKSB3aWxsIHByZXZlbnQgdGhpcy4gQW5kIHR4IGludGVycnVw
dCBpcyBubwo+PiBsb25nZXIgbmVlZGVkIG5vdy4KPj4KPj4gU2lnbmVkLW9mZi1ieTogU2h1eXUg
V2VpPHN5LndAb3V0bG9vay5jb20+Cj4gVGVzdGVkLWJ5OiBNaWNoYWVsIE5pZXdvZWhuZXI8bGlu
dXhAbW5pZXdvZWhuZXIuZGU+ClRlc3RlZC1ieTogWGluZyBaaGVuZyA8emhlbmd4aW5nQHJvY2st
Y2hpcHMuY29tPgoKVGhhbmtzLgoKLS0gCi0gWGluZyBaaGVuZwoKCgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eC1yb2NrY2hpcCBtYWlsaW5nIGxp
c3QKTGludXgtcm9ja2NoaXBAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFk
ZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LXJvY2tjaGlwCg==
