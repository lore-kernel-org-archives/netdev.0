From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [SUNGEM] LLTX support
Date: Wed, 15 Sep 2004 23:43:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f04091514433c9e13c8@mail.gmail.com>
References: <5cac192f04091423453ae3cb@mail.gmail.com>
	 <20040915083559.6c36759f.davem@davemloft.net>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_159_24512419.1095284596697"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040915083559.6c36759f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_159_24512419.1095284596697
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wed, 15 Sep 2004 08:35:59 -0700, David S. Miller <davem@davemloft.net> wrote:
> On Wed, 15 Sep 2004 08:45:21 +0200
> Eric Lemoine <eric.lemoine@gmail.com> wrote:
> 
> > The attached patch adds LLTX support to SunGEM NAPI. The tx_lock patch
> > I just sent must be applied first.
> 
> Also applied, thanks Eric.
> 
> I remember you mentioning yesterday that Harald's sungem NAPI
> patch had netpoll support, can you cook up a patch that adds
> it for current sungem?

Patch attached. Unlike Harald's, this patch doesn't disable_irq before
calling gem_interrupt because gem_interrupt is safe to reentrance.
Hopefully this is correct...

-- 
Eric

------=_Part_159_24512419.1095284596697
Content-Type: application/octet-stream; name="rset-sungem_netpoll-2-6-9-rc1.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="rset-sungem_netpoll-2-6-9-rc1.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5bGUgcGF0Y2guCiMK
IyBDaGFuZ2VTZXQKIyAgIDIwMDQvMDkvMTUgMjM6Mzc6MjQrMDI6MDAgZXJpYy5sZW1vaW5lQGdt
YWlsLmNvbSAKIyAgIFtTVU5HRU1dIG5ldHBvbGwgc3VwcG9ydAojICAgCiMgICBTaWduZWQtb2Zm
LWJ5OiBFcmljIExlbW9pbmUgPGVyaWMubGVtb2luZUBnbWFpbC5jb20+CiMgCiMgZHJpdmVycy9u
ZXQvc3VuZ2VtLmMKIyAgIDIwMDQvMDkvMTUgMjM6Mzc6MTUrMDI6MDAgZXJpYy5sZW1vaW5lQGdt
YWlsLmNvbSArMTYgLTAKIyAgIFtTVU5HRU1dIG5ldHBvbGwgc3VwcG9ydAojICAgCiMgICBTaWdu
ZWQtb2ZmLWJ5OiBFcmljIExlbW9pbmUgPGVyaWMubGVtb2luZUBnbWFpbC5jb20+CiMgCmRpZmYg
LU5ydSBhL2RyaXZlcnMvbmV0L3N1bmdlbS5jIGIvZHJpdmVycy9uZXQvc3VuZ2VtLmMKLS0tIGEv
ZHJpdmVycy9uZXQvc3VuZ2VtLmMJMjAwNC0wOS0xNSAyMzozODoxMiArMDI6MDAKKysrIGIvZHJp
dmVycy9uZXQvc3VuZ2VtLmMJMjAwNC0wOS0xNSAyMzozODoxMiArMDI6MDAKQEAgLTUsNiArNSw5
IEBACiAgKiAKICAqIFN1cHBvcnQgZm9yIEFwcGxlIEdNQUMgYW5kIGFzc29ydGVkIFBIWXMgYnkK
ICAqIEJlbmphbWluIEhlcnJlbnNjbWlkdCAoYmVuaEBrZXJuZWwuY3Jhc2hpbmcub3JnKQorICoK
KyAqIE5BUEkgYW5kIE5FVFBPTEwgc3VwcG9ydAorICogKEMpIDIwMDQgYnkgRXJpYyBMZW1vaW5l
IChlcmljLmxlbW9pbmVAZ21haWwuY29tKQogICogCiAgKiBUT0RPOiAKICAqICAtIEdldCByaWQg
b2YgYWxsIHRob3NlIG5hc3R5IG1kZWxheSdzIGFuZCByZXBsYWNlIHRoZW0KQEAgLTg5OCw2ICs5
MDEsMTYgQEAKIAlyZXR1cm4gSVJRX0hBTkRMRUQ7CiB9CiAKKyNpZmRlZiBDT05GSUdfTkVUX1BP
TExfQ09OVFJPTExFUgorc3RhdGljIHZvaWQgZ2VtX3BvbGxfY29udHJvbGxlcihzdHJ1Y3QgbmV0
X2RldmljZSAqZGV2KQoreworCS8qIGdlbV9pbnRlcnJ1cHQgaXMgc2FmZSB0byByZWVudHJhbmNl
IHNvIG5vIG5lZWQKKwkgKiB0byBkaXNhYmxlX2lycSBoZXJlLgorCSAqLworCWdlbV9pbnRlcnJ1
cHQoZGV2LT5pcnEsIGRldiwgTlVMTCk7Cit9CisjZW5kaWYKKwogc3RhdGljIHZvaWQgZ2VtX3R4
X3RpbWVvdXQoc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKIAlzdHJ1Y3QgZ2VtICpncCA9IGRl
di0+cHJpdjsKQEAgLTI5MzQsNiArMjk0Nyw5IEBACiAJZGV2LT5jaGFuZ2VfbXR1ID0gZ2VtX2No
YW5nZV9tdHU7CiAJZGV2LT5pcnEgPSBwZGV2LT5pcnE7CiAJZGV2LT5kbWEgPSAwOworI2lmZGVm
IENPTkZJR19ORVRfUE9MTF9DT05UUk9MTEVSCisgICAgICAgIGRldi0+cG9sbF9jb250cm9sbGVy
ID0gZ2VtX3BvbGxfY29udHJvbGxlcjsKKyNlbmRpZgogCiAJaWYgKHJlZ2lzdGVyX25ldGRldihk
ZXYpKSB7CiAJCXByaW50ayhLRVJOX0VSUiBQRlggIkNhbm5vdCByZWdpc3RlciBuZXQgZGV2aWNl
LCAiCg==
------=_Part_159_24512419.1095284596697--
