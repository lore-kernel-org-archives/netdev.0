From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix sleep inside atomic
Date: Tue, 7 Sep 2010 07:55:55 +0200
Message-ID: <4C85D3EB.7040208@st.com>
References: <1283742379-9610-1-git-send-email-peppe.cavallaro@st.com>
 <20100906.131107.183045782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="_002_4C85D3EB7040208stcom_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jiri Slaby <jirislaby@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:60063 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756102Ab0IGF42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 01:56:28 -0400
In-Reply-To: <20100906.131107.183045782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_4C85D3EB7040208stcom_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

 Hi David,
On 9/6/2010 10:11 PM, David Miller wrote:
>
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Mon,  6 Sep 2010 05:06:19 +0200
>
> > We cannot use spinlock when kmalloc is invoked with
> > GFP_KERNEL flag because it can sleep.
> > So this patch reviews the usage of spinlock within the
> > stmmac_resume function avoing this bug.
> >
> > Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>
> Applied, but you are extremely guilty of the sin of omission
> here.
>
> Why in the world did you not at least CC: Jiri, the person
> who reported this problem?  You should do that at a minimum
> when someone reports a problem with code you are fixing.
>
You are right and I'm awfully sorry for this (sorry Jiri!).
>
> And in this case he definitely deserves a
>
> Reported-by:
>
> tag in the commit message as well.
>
> Please don't fail to acknowledge a reporter's efforts like
> this ever again.
>

This will never happen.
I've attached the patch reviewed as well.

I hope this has not hurt Jiri.

Regards,
Peppe

P.S. I'm waiting for my third baby so I'm quite stressed and busy in
these days.
I wanted fixed the issue spotted by Jiri but I was too fast to send the
patch.
I hope this can help to save me ;-)

--_002_4C85D3EB7040208stcom_
Content-Type: text/x-patch; name="0001-stmmac-fix-sleep-inside-atomic.patch"
Content-Description: 0001-stmmac-fix-sleep-inside-atomic.patch
Content-Disposition: attachment;
	filename="0001-stmmac-fix-sleep-inside-atomic.patch"; size=1583;
	creation-date="Tue, 07 Sep 2010 07:55:57 GMT";
	modification-date="Tue, 07 Sep 2010 07:55:57 GMT"
Content-Transfer-Encoding: base64

RnJvbSA4OGY0YWM3ZTkwYmZlNGM1NDMxNmE3YWM1ZTA2NDI2NGUxYWNmNmE0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQ0KRnJvbTogR2l1c2VwcGUgQ2F2YWxsYXJvIDxwZXBwZS5jYXZhbGxhcm9A
c3QuY29tPg0KRGF0ZTogTW9uLCA2IFNlcCAyMDEwIDA1OjAyOjExICswMjAwDQpTdWJqZWN0OiBb
UEFUQ0hdIHN0bW1hYzogZml4IHNsZWVwIGluc2lkZSBhdG9taWMNCg0KV2UgY2Fubm90IHVzZSBz
cGlubG9jayB3aGVuIGttYWxsb2MgaXMgaW52b2tlZCB3aXRoDQpHRlBfS0VSTkVMIGZsYWcgYmVj
YXVzZSBpdCBjYW4gc2xlZXAuDQpTbyB0aGlzIHBhdGNoIHJldmlld3MgdGhlIHVzYWdlIG9mIHNw
aW5sb2NrIHdpdGhpbiB0aGUNCnN0bW1hY19yZXN1bWUgZnVuY3Rpb24gYXZvaW5nIHRoaXMgYnVn
Lg0KDQpTaWduZWQtb2ZmLWJ5OiBHaXVzZXBwZSBDYXZhbGxhcm8gPHBlcHBlLmNhdmFsbGFyb0Bz
dC5jb20+DQpSZXBvcnRlZC1ieTogSmlyaSBTbGFieSA8amlyaXNsYWJ5QGdtYWlsLmNvbT4NCi0t
LQ0KIGRyaXZlcnMvbmV0L3N0bW1hYy9zdG1tYWNfbWFpbi5jIHwgICAgOSArKysrLS0tLS0NCiAx
IGZpbGVzIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkNCg0KZGlmZiAt
LWdpdCBhL2RyaXZlcnMvbmV0L3N0bW1hYy9zdG1tYWNfbWFpbi5jIGIvZHJpdmVycy9uZXQvc3Rt
bWFjL3N0bW1hY19tYWluLmMNCmluZGV4IGJiYjc5NTEuLmE5YmVmZDYgMTAwNjQ0DQotLS0gYS9k
cml2ZXJzL25ldC9zdG1tYWMvc3RtbWFjX21haW4uYw0KKysrIGIvZHJpdmVycy9uZXQvc3RtbWFj
L3N0bW1hY19tYWluLmMNCkBAIC0xODY1LDE1ICsxODY1LDE1IEBAIHN0YXRpYyBpbnQgc3RtbWFj
X3Jlc3VtZShzdHJ1Y3QgcGxhdGZvcm1fZGV2aWNlICpwZGV2KQ0KIAlpZiAoIW5ldGlmX3J1bm5p
bmcoZGV2KSkNCiAJCXJldHVybiAwOw0KIA0KLQlzcGluX2xvY2soJnByaXYtPmxvY2spOw0KLQ0K
IAlpZiAocHJpdi0+c2h1dGRvd24pIHsNCiAJCS8qIFJlLW9wZW4gdGhlIGludGVyZmFjZSBhbmQg
cmUtaW5pdCB0aGUgTUFDL0RNQQ0KLQkJICAgYW5kIHRoZSByaW5ncy4gKi8NCisJCSAgIGFuZCB0
aGUgcmluZ3MgKGkuZS4gb24gaGliZXJuYXRpb24gc3RhZ2UpICovDQogCQlzdG1tYWNfb3Blbihk
ZXYpOw0KLQkJZ290byBvdXRfcmVzdW1lOw0KKwkJcmV0dXJuIDA7DQogCX0NCiANCisJc3Bpbl9s
b2NrKCZwcml2LT5sb2NrKTsNCisNCiAJLyogUG93ZXIgRG93biBiaXQsIGludG8gdGhlIFBNIHJl
Z2lzdGVyLCBpcyBjbGVhcmVkDQogCSAqIGF1dG9tYXRpY2FsbHkgYXMgc29vbiBhcyBhIG1hZ2lj
IHBhY2tldCBvciBhIFdha2UtdXAgZnJhbWUNCiAJICogaXMgcmVjZWl2ZWQuIEFueXdheSwgaXQn
cyBiZXR0ZXIgdG8gbWFudWFsbHkgY2xlYXINCkBAIC0xOTAxLDcgKzE5MDEsNiBAQCBzdGF0aWMg
aW50IHN0bW1hY19yZXN1bWUoc3RydWN0IHBsYXRmb3JtX2RldmljZSAqcGRldikNCiANCiAJbmV0
aWZfc3RhcnRfcXVldWUoZGV2KTsNCiANCi1vdXRfcmVzdW1lOg0KIAlzcGluX3VubG9jaygmcHJp
di0+bG9jayk7DQogCXJldHVybiAwOw0KIH0NCi0tIA0KMS41LjUuNg0KDQo=

--_002_4C85D3EB7040208stcom_--
