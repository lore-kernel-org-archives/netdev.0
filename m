From: "Yuniverg, Michael" <michael.yuniverg@intel.com>
Subject: RE: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Tue, 7 Jun 2011 15:55:29 +0300
Message-ID: <988B94264D669747BBD6A7EF86DE1C84155DDFEC67@hasmsx504.ger.corp.intel.com>
References: <1300357750.2589.46.camel@macbook.infradead.org>
 <1306537651.2029.196.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1367200668=="
Cc: "Yedvab, Nadav" <nadav.yedvab@intel.com>
To: David Woodhouse <dwmw2@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34142 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752048Ab1FGMzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:55:46 -0400
In-Reply-To: <1306537651.2029.196.camel@i7.infradead.org>
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--===============1367200668==
MIME-Version: 1.0
Content-Language: en-US
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_005E_01CC252B.535D0BD0"

------=_NextPart_000_005E_01CC252B.535D0BD0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hi David, all

I went  as far as to see that different Kernel code is responsible for =
IPv4 and IPv6 implementation.
We closed the issue in current version as a limitation, but of course we =
would be happy to get rid of that.
Probably it would be a bit easier to get support in  the next version, =
since we are going to base on another Linux flavor, which is based on =
latest Kernel.

Michael

> -----Original Message-----
> From: David Woodhouse [mailto:dwmw2@infradead.org]
> Sent: Saturday, May 28, 2011 2:08 AM
> To: netdev@vger.kernel.org
> Cc: Yuniverg, Michael; Yedvab, Nadav
> Subject: Re: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
>=20
> On Thu, 2011-03-17 at 10:29 +0000, David Woodhouse wrote:
> > We've discovered strange behaviour when we listen on in6addr_any and
> > use SO_BINDTODEVICE to bind to the lo device.
> >
> > We can connect to any IPv4 address that is local to the machine, on
> > any interface. (This is true whether we listen on =
AF_INET6/in6addr_any
> > and accept IPv4 connections on the IPv6 socket, or whether we just
> > listen on AF_INET/INADDR_ANY).
> >
> > The IPv6 behaviour is different =E2=80=94 the only IPv6 address that =
we can
> > connect to is ::1.
>=20
> Michael, Nadav =E2=80=95 did you ever get any further with this?
>=20
> --
> dwmw2


------=_NextPart_000_005E_01CC252B.535D0BD0
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIISEjCCAyAw
ggKJoAMCAQICBDXe9M8wDQYJKoZIhvcNAQEFBQAwTjELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0Vx
dWlmYXgxLTArBgNVBAsTJEVxdWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw05
ODA4MjIxNjQxNTFaFw0xODA4MjIxNjQxNTFaME4xCzAJBgNVBAYTAlVTMRAwDgYDVQQKEwdFcXVp
ZmF4MS0wKwYDVQQLEyRFcXVpZmF4IFNlY3VyZSBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwgZ8wDQYJ
KoZIhvcNAQEBBQADgY0AMIGJAoGBAMFdsVhnCGLuoJotHwhtkRRomAoe/toEbxOEYiHD0XzOnwXg
uAHwTjTs4oqVBGSs8WtTXwWzy2eAv0ICjv7dAQns4QAUT/z78AzdQ7pbK+EfgHCZFVeTFvEPl2q3
wmgjHMxNWTCsUR47ryvW7mNFe8XZX1DS41APOojnvxT94Me5AgMBAAGjggEJMIIBBTBwBgNVHR8E
aTBnMGWgY6BhpF8wXTELMAkGA1UEBhMCVVMxEDAOBgNVBAoTB0VxdWlmYXgxLTArBgNVBAsTJEVx
dWlmYXggU2VjdXJlIENlcnRpZmljYXRlIEF1dGhvcml0eTENMAsGA1UEAxMEQ1JMMTAaBgNVHRAE
EzARgQ8yMDE4MDgyMjE2NDE1MVowCwYDVR0PBAQDAgEGMB8GA1UdIwQYMBaAFEjmaPkr0rKV10fY
IyAQTzOYkJ/UMB0GA1UdDgQWBBRI5mj5K9KylddH2CMgEE8zmJCf1DAMBgNVHRMEBTADAQH/MBoG
CSqGSIb2fQdBAAQNMAsbBVYzLjBjAwIGwDANBgkqhkiG9w0BAQUFAAOBgQBYzinq/Pfetc4CuRe1
hdG54+CVzCUxDQCmkm5/tpJjnlCV0Zpv5BHeY4VumO6o/1rI01WyZnFX3sAh6z0qpyNJAQSGQnv8
7n+iFlK1Z2fTQNs7JliyKHc9rhR3Ydb6KmYnoA36p3Nc6nDxlCFlRF/6/O8paKmih3nvee9PrAd3
ODCCAz0wggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UE
ChMHRXF1aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
MB4XDTA2MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoT
EUludGVsIENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kg
Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATD
IsV2xDyt30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUj
ZzTZFq2N4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZv
uSQ0E11yYL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4
lz36wOdNZn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+
iC1HawJdAgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0
Vgaj7TdUDDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3Nl
Y3VyZWNhLmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69
tOkIP4SgDJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3j
Mfr900fXZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAA
AAAACDANBgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9y
YXRpb24xJzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUx
OTI3MjZaFw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jw
b3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUd
HvWG+IcQHVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jX
EfTBvTnUSFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa
4k6YN94zlrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigi
F2kEn9xVh1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38C
AwEAAaOCAlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYx
MCvFMAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2
ekKQ/5Ktim+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQa
xgxKxEdvqNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3Lmlu
dGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3kl
MjBDQS5jcmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYw
gdMwYwYIKwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNh
dGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcw
AoZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMv
SW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUA
A4IBAQCxtQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1
cChqpb22U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFW
py7rB3Vm/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjs
kTENPmhbVbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8
RHCJXkPau/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGGzCCBQOgAwIBAgIKOOTbFgABAABZ
oDANBgkqhkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRp
b24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwODI1
MTA1NDA2WhcNMTMwODA5MTA1NDA2WjBHMRowGAYDVQQDExFZdW5pdmVyZywgTWljaGFlbDEpMCcG
CSqGSIb3DQEJARYabWljaGFlbC55dW5pdmVyZ0BpbnRlbC5jb20wggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQC0qJdXKSTYPjJcS3boed2dB+7LkB7I+9/bVaepKADP5U/1jf4EddKlX3hx
8jVqe2XmMuV7UEkXZwAHwzQXmDHEZG04wfBFltCw5HV2OyaB49EChMuklvBIgrxfA9N6RJUMr0td
GFzJeus1KgyLgrctNH9kCoDqCErS66rimOAkyELq4aUGuh5HQZ5yhOz00ScWdgbLznrlXPrE6+Le
hZCPgvgwJhlmSrPC5awyZrL++liK2qydwKdBnNxBv9n1OiDjrDC63Ta2a1DC5ZmYMP2aVpHkgUrh
xYQ5M6y1+cOt52sI3Iy0Kqg8KBlJR6ipc/yImK7PD6OPu9gouEPQ0DiNAgMBAAGjggL4MIIC9DAL
BgNVHQ8EBAMCB4AwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KR
wAlngd69OZXwQwIBZAIBCDAdBgNVHQ4EFgQU9uUca0VNQ3FlzKFOk3hge0WsdSEwHwYDVR0jBBgw
FoAUDsYq91myCBCQJW/D3f2KZjEwK8Uwgc8GA1UdHwSBxzCBxDCBwaCBvqCBu4ZXaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNz
dWluZyUyMENBJTIwM0IoMSkuY3JshmBodHRwOi8vY2VydGlmaWNhdGVzLmludGVsLmNvbS9yZXBv
c2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigx
KS5jcmwwgfUGCCsGAQUFBwEBBIHoMIHlMGwGCCsGAQUFBzAChmBodHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJc3N1
aW5nJTIwQ0ElMjAzQigxKS5jcnQwdQYIKwYBBQUHMAKGaWh0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50
ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNydDAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoD
DDApBgkrBgEEAYI3FQoEHDAaMAoGCCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwUQYDVR0RBEowSKAq
BgorBgEEAYI3FAIDoBwMGm1pY2hhZWwueXVuaXZlcmdAaW50ZWwuY29tgRptaWNoYWVsLnl1bml2
ZXJnQGludGVsLmNvbTANBgkqhkiG9w0BAQUFAAOCAQEAR6N3GqQ7c2uIWvnKcma+QE3bjDBdGeHd
uaIxEQeHtCpiGF9vKyqWsyxYidZy9oeg6ABzdaVruBlH7+Vp3bFn65NPfhzi7d8576nMYnOOUIiD
6ReW46KvlO9SR7OfTXjp94Izz3MD7vQCmTFZg/RnnPv4sbY7sicvMP3lW9nr4brcsIg42NqH+80o
/kU1ixwsQlBioMZlVKjSVnMrzRK2vHOz7F+g0MZ746o7/0qz8rInV9TyhbYb29mBWJ114nnGlxVl
n19Sfbh4RJW0YoUtF7YFZ8pF354CSSh7sTEVkTHbeUlSqILYYfLPL6FLe59lVGBx/LLGF3jyUir7
wsvQIzGCAjgwggI0AgEBMGQwVjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVsIENvcnBvcmF0
aW9uMSswKQYDVQQDEyJJbnRlbCBFeHRlcm5hbCBCYXNpYyBJc3N1aW5nIENBIDNCAgo45NsWAAEA
AFmgMAkGBSsOAwIaBQCggaowGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUx
DxcNMTEwNjA3MTI1NTI5WjAjBgkqhkiG9w0BCQQxFgQUrTQ0Va7QFYGVBXv16fo7a6g+CY0wSwYJ
KoZIhvcNAQkPMT4wPDAHBgUrDgMCGjALBglghkgBZQMEAgMwCwYJYIZIAWUDBAICMAsGCWCGSAFl
AwQCATAKBggqhkiG9w0CBTANBgkqhkiG9w0BAQEFAASCAQBuX6PA6zgkvARU3n3yzcgTmInx9hB1
0SWYxXM/pHDsAEpTuVmPflFpDAEMmqpAAxqGzsS8GQmJ7oLmF2MiWwf94iI/PEYxolmL1CPoleXv
YNU9wRrk/bCe+3Afny+Puk7Akfw+MnuW2eItH0FY388XSP87vVTufw01QCCWGItRO6OYN8fh4xkG
1Enfpom2NdSkcnTWFkKXXR9Psd37GTmUG4RpFT2BBWbzWk0YUJzulOGl3Pd1m6V5Dx0Z7F+JPjPf
FCt9t8jhvWvOYgUm9n3kmr2h4m9OvGZJGEH7YhQI1ZscmKjvuOBzuK4ZXYprVt3Y1mpzNRxyw3WX
NrPk0UE5AAAAAAAA

------=_NextPart_000_005E_01CC252B.535D0BD0--

--===============1367200668==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.

--===============1367200668==--
