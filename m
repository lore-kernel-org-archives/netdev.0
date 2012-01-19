From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: iwlwifi worse than ever in current git.
Date: Thu, 19 Jan 2012 20:38:35 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3079A3F@HASMSX103.ger.corp.intel.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
 <20120111195055.GA5140@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3064AF5@HASMSX103.ger.corp.intel.com>
 <CANUX_P3UHz-Pr_M1H5pAbmKDY70es7nxkWSDGXG6-hvrPAMCJw@mail.gmail.com>
 <20120119182955.GA1630@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_0BA3FCBA62E2DC44AF3030971E174FB3079A3FHASMSX103gercorpi_"
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--_002_0BA3FCBA62E2DC44AF3030971E174FB3079A3FHASMSX103gercorpi_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

>=20
> >
> > On Thu, Jan 19, 2012 at 08:47:28AM +0200, Emmanuel Grumbach wrote:
> >  > Ok, I finally had a change to take a closer look at this. Please run
> >  > with debug=3D0xC0000000.
> >  >
> >  > This will be noisy, but I guess we have no choice...
> >  > I will be travelling next week, so...
> >
> > Ah. Got it. I had to do a large download (a kernel tarball was enough) =
to
> > trigger it.
> > Log is at http://davej.fedorapeople.org/iwl-debug.txt
> >
> > The download began at around 13:17 in the log.
> > It hung shortly afterwards.
> >
> > 	Dave
>=20
> Thanks for that one. Really helpful. I need to send you a patch to get a
> little more data. I don't know when I will be able to do it though.

Can you please retry with the patch attached ?
Thanks
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--_002_0BA3FCBA62E2DC44AF3030971E174FB3079A3FHASMSX103gercorpi_
Content-Type: application/octet-stream; name="ampdu_debug.patch"
Content-Description: ampdu_debug.patch
Content-Disposition: attachment; filename="ampdu_debug.patch"; size=2887;
	creation-date="Thu, 19 Jan 2012 18:30:58 GMT";
	modification-date="Thu, 19 Jan 2012 18:30:58 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2l3bHdpZmkvaXdsLWFnbi10eC5jIGIv
ZHJpdmVycy9uZXQvd2lyZWxlc3MvaXdsd2lmaS9pd2wtYWduLXR4LmMKaW5kZXggZDlkNzU4ZS4u
NmQ5ZGYwZCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvaXdsd2lmaS9pd2wtYWdu
LXR4LmMKKysrIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvaXdsd2lmaS9pd2wtYWduLXR4LmMKQEAg
LTgzOSwxMSArODM5LDEzIEBAIHN0YXRpYyB2b2lkIGl3bF9yeF9yZXBseV90eF9hZ2coc3RydWN0
IGl3bF9wcml2ICpwcml2LAogCQkJICAgICAgQUdHX1RYX1NUQVRFX0FCT1JUX01TSykpCiAJCQlj
b250aW51ZTsKIAorLyoKIAkJSVdMX0RFQlVHX1RYX1JFUExZKHByaXYsICJzdGF0dXMgJXMgKDB4
JTA4eCksICIKIAkJCQkgICAidHJ5LWNvdW50ICgweCUwOHgpXG4iLAogCQkJCSAgIGl3bF9nZXRf
YWdnX3R4X2ZhaWxfcmVhc29uKGZzdGF0dXMpLAogCQkJCSAgIGZzdGF0dXMgJiBBR0dfVFhfU1RB
VFVTX01TSywKIAkJCQkgICBmc3RhdHVzICYgQUdHX1RYX1RSWV9NU0spOworKi8KIAl9CiB9CiAK
QEAgLTEwMTYsOCArMTAxOCw4IEBAIGludCBpd2xhZ25fcnhfcmVwbHlfdHgoc3RydWN0IGl3bF9w
cml2ICpwcml2LCBzdHJ1Y3QgaXdsX3J4X21lbV9idWZmZXIgKnJ4YiwKIAkJaXdsX3J4X3JlcGx5
X3R4X2FnZyhwcml2LCB0eF9yZXNwKTsKIAogCWlmICh0eF9yZXNwLT5mcmFtZV9jb3VudCA9PSAx
KSB7Ci0JCXUxNiBuZXh0X3JlY2xhaW1lZCA9IGxlMTZfdG9fY3B1KHR4X3Jlc3AtPnNlcV9jdGwp
OwotCQluZXh0X3JlY2xhaW1lZCA9IFNFUV9UT19TTihuZXh0X3JlY2xhaW1lZCArIDB4MTApOwor
CQl1MTYgbmV4dF9yZWNsYWltZWRfID0gbGUxNl90b19jcHUodHhfcmVzcC0+c2VxX2N0bCk7CisJ
CXUxNiBuZXh0X3JlY2xhaW1lZCA9IFNFUV9UT19TTihuZXh0X3JlY2xhaW1lZF8gKyAweDEwKTsK
IAogCQlpZiAoaXNfYWdnKSB7CiAJCQkvKiBJZiB0aGlzIGlzIGFuIGFnZ3JlZ2F0aW9uIHF1ZXVl
LCB3ZSBjYW4gcmVseSBvbiB0aGUKQEAgLTEwMzcsOCArMTAzOSw4IEBAIGludCBpd2xhZ25fcnhf
cmVwbHlfdHgoc3RydWN0IGl3bF9wcml2ICpwcml2LCBzdHJ1Y3QgaXdsX3J4X21lbV9idWZmZXIg
KnJ4YiwKIAkJX19za2JfcXVldWVfaGVhZF9pbml0KCZza2JzKTsKIAkJcHJpdi0+dGlkX2RhdGFb
c3RhX2lkXVt0aWRdLm5leHRfcmVjbGFpbWVkID0gbmV4dF9yZWNsYWltZWQ7CiAKLQkJSVdMX0RF
QlVHX1RYX1JFUExZKHByaXYsICJOZXh0IHJlY2xhaW1lZCBwYWNrZXQ6JWQiLAotCQkJCQkgIG5l
eHRfcmVjbGFpbWVkKTsKKwkJSVdMX0RFQlVHX1RYX1JFUExZKHByaXYsICJOZXh0IHJlY2xhaW1l
ZCBwYWNrZXQ6JWQsIF8lZCBpc19BZ2cgJWQgU1NOICVkIiwKKwkJCQkJICBuZXh0X3JlY2xhaW1l
ZCwgbmV4dF9yZWNsYWltZWRfLCBpc19hZ2csIHNzbik7CiAKIAkJLyp3ZSBjYW4gZnJlZSB1bnRp
bCBzc24gJSBxLm5fYmQgbm90IGluY2x1c2l2ZSAqLwogCQlXQVJOX09OKGl3bF90cmFuc19yZWNs
YWltKHRyYW5zKHByaXYpLCBzdGFfaWQsIHRpZCwgdHhxX2lkLApAQCAtMTE0OSwxNyArMTE1MSw2
IEBAIGludCBpd2xhZ25fcnhfcmVwbHlfY29tcHJlc3NlZF9iYShzdHJ1Y3QgaXdsX3ByaXYgKnBy
aXYsCiAJCXJldHVybiAwOwogCX0KIAotCV9fc2tiX3F1ZXVlX2hlYWRfaW5pdCgmcmVjbGFpbWVk
X3NrYnMpOwotCi0JLyogUmVsZWFzZSBhbGwgVEZEcyBiZWZvcmUgdGhlIFNTTiwgaS5lLiBhbGwg
VEZEcyBpbiBmcm9udCBvZgotCSAqIGJsb2NrLWFjayB3aW5kb3cgKHdlIGFzc3VtZSB0aGF0IHRo
ZXkndmUgYmVlbiBzdWNjZXNzZnVsbHkKLQkgKiB0cmFuc21pdHRlZCAuLi4gaWYgbm90LCBpdCdz
IHRvbyBsYXRlIGFueXdheSkuICovCi0JaWYgKGl3bF90cmFuc19yZWNsYWltKHRyYW5zKHByaXYp
LCBzdGFfaWQsIHRpZCwgc2NkX2Zsb3csCi0JCQkgICAgICBiYV9yZXNwX3NjZF9zc24sIDAsICZy
ZWNsYWltZWRfc2ticykpIHsKLQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmcHJpdi0+c2hyZC0+
c3RhX2xvY2ssIGZsYWdzKTsKLQkJcmV0dXJuIDA7Ci0JfQotCiAJSVdMX0RFQlVHX1RYX1JFUExZ
KHByaXYsICJSRVBMWV9DT01QUkVTU0VEX0JBIFslZF0gUmVjZWl2ZWQgZnJvbSAlcE0sICIKIAkJ
CSAgICJzdGFfaWQgPSAlZFxuIiwKIAkJCSAgIGFnZy0+d2FpdF9mb3JfYmEsCkBAIC0xMTcxLDYg
KzExNjIsMTcgQEAgaW50IGl3bGFnbl9yeF9yZXBseV9jb21wcmVzc2VkX2JhKHN0cnVjdCBpd2xf
cHJpdiAqcHJpdiwKIAkJCSAgICh1bnNpZ25lZCBsb25nIGxvbmcpbGU2NF90b19jcHUoYmFfcmVz
cC0+Yml0bWFwKSwKIAkJCSAgIHNjZF9mbG93LCBiYV9yZXNwX3NjZF9zc24pOwogCisJX19za2Jf
cXVldWVfaGVhZF9pbml0KCZyZWNsYWltZWRfc2ticyk7CisKKwkvKiBSZWxlYXNlIGFsbCBURkRz
IGJlZm9yZSB0aGUgU1NOLCBpLmUuIGFsbCBURkRzIGluIGZyb250IG9mCisJICogYmxvY2stYWNr
IHdpbmRvdyAod2UgYXNzdW1lIHRoYXQgdGhleSd2ZSBiZWVuIHN1Y2Nlc3NmdWxseQorCSAqIHRy
YW5zbWl0dGVkIC4uLiBpZiBub3QsIGl0J3MgdG9vIGxhdGUgYW55d2F5KS4gKi8KKwlpZiAoaXds
X3RyYW5zX3JlY2xhaW0odHJhbnMocHJpdiksIHN0YV9pZCwgdGlkLCBzY2RfZmxvdywKKwkJCSAg
ICAgIGJhX3Jlc3Bfc2NkX3NzbiwgMCwgJnJlY2xhaW1lZF9za2JzKSkgeworCQlzcGluX3VubG9j
a19pcnFyZXN0b3JlKCZwcml2LT5zaHJkLT5zdGFfbG9jaywgZmxhZ3MpOworCQlyZXR1cm4gMDsK
Kwl9CisKIAkvKiBNYXJrIHRoYXQgdGhlIGV4cGVjdGVkIGJsb2NrLWFjayByZXNwb25zZSBhcnJp
dmVkICovCiAJYWdnLT53YWl0X2Zvcl9iYSA9IGZhbHNlOwogCg==

--_002_0BA3FCBA62E2DC44AF3030971E174FB3079A3FHASMSX103gercorpi_--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
