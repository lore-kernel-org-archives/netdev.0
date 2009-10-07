From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] znet.c sleeping function called from
	invalid context
Date: Wed, 7 Oct 2009 14:44:45 -0400
Message-ID: <8bd0f97a0910071144k1d0bf30bv60656181edae8af7@mail.gmail.com>
References: <200910071847.38163.strakh@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexander Strakh <strakh-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        uclinux-dist-devel <uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>,
        Linux Kernlel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Hennerich <michael.hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <200910071847.38163.strakh-ufN2psIa012HXe+LvDLADg@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

T24gV2VkLCBPY3QgNywgMjAwOSBhdCAxNDo0NywgQWxleGFuZGVyIFN0cmFraCB3cm90ZToKPiDC
oCDCoCDCoCDCoEtFUk5FTF9WRVJTSU9OOiAyLjYuMzEKPiDCoCDCoCDCoCDCoERFU0NSSUJFOgo+
IERyaXZlciBkcml2ZXJzL25ldC96bmV0LmMgbWlnaHQgc2xlZXAgaW4gYXRvbWljIGNvbnRleHQs
IGJlY2F1c2UgaXQgY2FsbHMKPiBmcmVlX2RtYSB1bmRlciBjbGFpbV9kbWFfbG9jazoKPgo+IC5k
cml2ZXJzL25ldC96bmV0LmM6Cj4gwqAxNjggc3RhdGljIGludCB6bmV0X3JlcXVlc3RfcmVzb3Vy
Y2VzIChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQo+IC4uLgo+IMKgMTg5IMKgIMKgIMKgIMKgZmxh
Z3MgPSBjbGFpbV9kbWFfbG9jaygpOwo+IMKgMTkwIMKgIMKgIMKgIMKgZnJlZV9kbWEgKHpuZXQt
PnR4X2RtYSk7Cj4gwqAxOTEgwqAgwqAgwqAgwqByZWxlYXNlX2RtYV9sb2NrIChmbGFncyk7Cj4g
Li4uCj4KPiBQYXRoIHRvIG1pZ2h0X3NsZWVwIG1hY3JvIGZyb20gem5ldF9yZXF1ZXN0X3Jlc291
cmNlczoKPiAxLiB6bmV0X3JlcXVlc3RfcmVzb3VyY2VzIGNhbGxzIGZyZWVfZG1hIGF0Cj4gYXJj
aC9ibGFja2Zpbi9rZXJuZWwvYmZpbl9kbWFfNXh4LmM6MTgxCj4gMi4gZnJlZV9kbWEgY2FsbHMg
YXJjaC9ibGFja2Zpbi9rZXJuZWwvYmZpbl9kbWFfNXh4LmM6MTk1CgppIGRvbnQgdGhpbmsgd2Ug
bmVlZCB0aGUgZG1hbG9jayBtdXRleC4gIGl0J3Mgb25seSB1c2VkIHRvIHByb3RlY3QKcmVhZC93
cml0ZXMgdG8gLmNoYW5fc3RhdHVzLCBhbmQgdGhhdCBzaG91bGQgYmUgYXRvbWljIGFscmVhZHku
Ci1taWtlCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fClVj
bGludXgtZGlzdC1kZXZlbCBtYWlsaW5nIGxpc3QKVWNsaW51eC1kaXN0LWRldmVsQGJsYWNrZmlu
LnVjbGludXgub3JnCmh0dHBzOi8vYmxhY2tmaW4udWNsaW51eC5vcmcvbWFpbG1hbi9saXN0aW5m
by91Y2xpbnV4LWRpc3QtZGV2ZWw=
