From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] [arch-x86] Allow SRAT integrity check to be skipped
Date: Tue, 07 Sep 2010 13:16:55 -0700
Message-ID: <1283890615.18468.11.camel@pjaxe>
References: <20100901213318.19353.54619.stgit@localhost.localdomain>
	 <20100902065731.GB29972@elte.hu> <20100902100308.GA17167@basil.fritz.box>
	 <20100903063934.GA25863@elte.hu> <1283888337.18468.9.camel@pjaxe>
	 <4C869AA3.6000103@zytor.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="sha1"; protocol="application/x-pkcs7-signature"; boundary="=-KzagmC3GXa+F/HUmQPr0"
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C869AA3.6000103@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-KzagmC3GXa+F/HUmQPr0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2010-09-07 at 13:03 -0700, H. Peter Anvin wrote:
> On 09/07/2010 12:38 PM, Peter P Waskiewicz Jr wrote:
> >=20
> > It's one SKU of a Nehalem-EX system.  The BIOS for that SKU has an issu=
e
> > with resolving SRAT hotplug enumeration, and screws up the table.  Othe=
r
> > SKU's of this same platform do not have the issue.  Efforts are underwa=
y
> > to get this BIOS fixed, but in the meantime, there's nothing for users
> > to work around the bug (aside from disabling memory hotplug in the
> > BIOS).  Another platform almost shipped with the same symptoms, but
> > caught it and had it fixed before it shipped (didn't catch it early
> > because Windows wasn't failing, and most of the testing on that platfor=
m
> > was done under Windows).
> >=20
> > I agree with Andi that adding DMI strings would be overkill and would
> > leave clutter once the BIOS is fixed.  I look at this patch as a
> > stop-gap measure for people to fall back on until a newer BIOS is
> > available to correct the NUMA enumeration issues.  Without it, we have
> > nothing to point users to when they run into this, waiting for a new
> > BIOS.
> >=20
>=20
> No, this is exactly the kind of stuff for which a DMI match is ideal.  A
> specific system with bounded propagation of the problem.  Thus, the DMI
> match acts as a whitelist -- "we know this system and it is safe to
> activate this hack on it."  This is a very good thing.
>=20
> If this is a production BIOS it should have this information.

Responding for both your and Ingo's last email, I'll work on getting a
DMI match for this system.

Thanks,
-PJ

--=-KzagmC3GXa+F/HUmQPr0
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIPAjCCAz0w
ggKmoAMCAQICAwWw/zANBgkqhkiG9w0BAQUFADBOMQswCQYDVQQGEwJVUzEQMA4GA1UEChMHRXF1
aWZheDEtMCsGA1UECxMkRXF1aWZheCBTZWN1cmUgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MB4XDTA2
MDIxNjE4MDEzMFoXDTE2MDIxOTE4MDEzMFowUjELMAkGA1UEBhMCVVMxGjAYBgNVBAoTEUludGVs
IENvcnBvcmF0aW9uMScwJQYDVQQDEx5JbnRlbCBFeHRlcm5hbCBCYXNpYyBQb2xpY3kgQ0EwggEi
MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDBpd/XOb9QVqEZ8mQ1042TdOIq3ATDIsV2xDyt
30yLyMR5Wjtus0bn3B+he89BiNO/LP6+rFzEwlD55PlX+HLGIKeNNG97dqyc30FElEUjZzTZFq2N
4e3kVJ/XAEEgANzV8v9qp7qWwxugPgfc3z9BkYot+CifozexHLb/hEZj+yISCU61kRZvuSQ0E11y
YL4dRgcglJeaHo3oX57rvIckaLsYV5/1Aj+R8DM1Ppk965XQAKsHfnyT7C4S50T4lVn4lz36wOdN
Zn/zegG1zp41lnoTFfT4KuKVJH5x7YD1p6KbgJCKLovnujGuohquBNfdXKpZkvz6pGv+iC1HawJd
AgMBAAGjgaAwgZ0wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBQaxgxKxEdvqNutK/D0Vgaj7TdU
DDA6BgNVHR8EMzAxMC+gLaArhilodHRwOi8vY3JsLmdlb3RydXN0LmNvbS9jcmxzL3NlY3VyZWNh
LmNybDAfBgNVHSMEGDAWgBRI5mj5K9KylddH2CMgEE8zmJCf1DAPBgNVHRMBAf8EBTADAQH/MA0G
CSqGSIb3DQEBBQUAA4GBABMQOK2kVKVIlUWwLTdywJ+e2O+PC/uQltK2F3lRyrPfBn69tOkIP4Sg
DJOfsxyobIrPLe75kBLw+Dom13OBDp/EMZJZ1CglQfVV8co9mT3aZMjSGGQiMgkJLR3jMfr900fX
ZKj5XeqCJ+JP0mEhJGEdVCY+FFlksJjV86fDrq1QMIIFijCCBHKgAwIBAgIKYSCKYgAAAAAACDAN
BgkqhkiG9w0BAQUFADBSMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24x
JzAlBgNVBAMTHkludGVsIEV4dGVybmFsIEJhc2ljIFBvbGljeSBDQTAeFw0wOTA1MTUxOTI3MjZa
Fw0xNTA1MTUxOTM3MjZaMFYxCzAJBgNVBAYTAlVTMRowGAYDVQQKExFJbnRlbCBDb3Jwb3JhdGlv
bjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSAzQjCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAKQEM1Wn9TU9vc9C+/Tc7KB+eiYElmrcEWE32WUdHvWG+IcQ
HVQsikTmMyKKojNLw2B5s6Iekc8ivDo/wCfjZzX9JyftMnc+AArc0la87Olybzm8K9jXEfTBvTnU
SFSiI9ZYefITdiUgqlAFuljFZEHYKYtLuhrRacpmQfP4mV63NKdc2bT804HRf6YptZFa4k6YN94z
lrGNrBuQQ74WFzz/jLBusbUpEkro6Mu/ZYFOFWQrV9lBhF9Ruk8yN+3N6n9fUo/qBigiF2kEn9xV
h1ykl7SCGL2jBUkXx4qgV27a6Si8lRRdgrHGtN/HWnSWlLXTH5l575H4Lq++77OFv38CAwEAAaOC
AlwwggJYMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFA7GKvdZsggQkCVvw939imYxMCvFMAsG
A1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQABMCMGCSsGAQQBgjcVAgQWBBQ5oFY2ekKQ/5Kt
im+VdMeSWb4QWTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAfBgNVHSMEGDAWgBQaxgxKxEdv
qNutK/D0Vgaj7TdUDDCBvQYDVR0fBIG1MIGyMIGvoIGsoIGphk5odHRwOi8vd3d3LmludGVsLmNv
bS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBQb2xpY3klMjBDQS5j
cmyGV2h0dHA6Ly9jZXJ0aWZpY2F0ZXMuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIw
RXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNybDCB4wYIKwYBBQUHAQEEgdYwgdMwYwYI
KwYBBQUHMAKGV2h0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvY2VydGlmaWNhdGVzL0lu
dGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMFBvbGljeSUyMENBLmNydDBsBggrBgEFBQcwAoZgaHR0
cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwl
MjBFeHRlcm5hbCUyMEJhc2ljJTIwUG9saWN5JTIwQ0EuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCx
tQEHchVQhXyjEqtMVUMe6gkmPsIczHxSeqNbo9dsD+6xbT65JT+oYgpIAtfEsYXeUJu1cChqpb22
U5bMAz7eaQcW5bzefufWvA6lg2048B8oczBj/q+5P5NpYrUO8jOmN4jTjfJq3ElZ7yFWpy7rB3Vm
/aN6ATYqWfMbS/xfh+JCxmH3droUmMJI0/aZJHsLtjbjFnNsHDNrJZX1vxlM78Lb1hjskTENPmhb
VbfTj5i/ZGnhv4tmI8QZPCNtcegXJrfhRl2D9bWpdTOPrWiLDUqzy1Z6KL7TcOS/PCl8RHCJXkPa
u/thTQCpIoDa2+c+3XA++gRTfAQ4svTO260NMIIGLzCCBRegAwIBAgIKf0es/QABAABRFTANBgkq
hkiG9w0BAQUFADBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgM0IwHhcNMTAwNDA5MDgyNzMw
WhcNMTMwMzI0MDgyNzMwWjBRMR8wHQYDVQQDExZXYXNraWV3aWN6IEpyLCBQZXRlciBQMS4wLAYJ
KoZIhvcNAQkBFh9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMIIBIjANBgkqhkiG9w0B
AQEFAAOCAQ8AMIIBCgKCAQEAxNvzDG+qS7UFSaYiqMqQr7exXHirCVe1tapLZoFlJZLPfqZsBsAA
UqARnY+v3RQj3WDmoIOtTMHxtnmo4pd5UXrsk+PraedGAilso9tkfp5ZjRjZo9LL06AZzjiBVfAx
gvyxMPsoKhdfFijzqSJRpc12kB662PAJWfyJO+f6lg5+Cd4KgRVGrpGI4bvBKEVGMeOqwD+kcVti
wRcqNygx35GqdcpJCCJqOSAJsLI3DR7tDvATeNzsasweaHgWonaK4D6qaHkoGx4VHknC6uNn/FK/
wXtFbXkeOrnRGJIzaZNsOBVhTou9w3NYU1EjuK75hZJ4Fd4/r1gHafxWD+VzrwIDAQABo4IDAjCC
Av4wCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbDjHWEmeVRg/2BKIWO
n1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFLtB44dRTSgY1071RY+nMiKRkn1PMB8GA1Ud
IwQYMBaAFA7GKvdZsggQkCVvw939imYxMCvFMIHPBgNVHR8EgccwgcQwgcGggb6ggbuGV2h0dHA6
Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUy
MElzc3VpbmclMjBDQSUyMDNCKDEpLmNybIZgaHR0cDovL2NlcnRpZmljYXRlcy5pbnRlbC5jb20v
cmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWluZyUyMENBJTIw
M0IoMSkuY3JsMIH1BggrBgEFBQcBAQSB6DCB5TBsBggrBgEFBQcwAoZgaHR0cDovL3d3dy5pbnRl
bC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIw
SXNzdWluZyUyMENBJTIwM0IoMSkuY3J0MHUGCCsGAQUFBzAChmlodHRwOi8vY2VydGlmaWNhdGVz
LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIwQmFz
aWMlMjBJc3N1aW5nJTIwQ0ElMjAzQigxKS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQBYea1KThIl9gNf
1uIob1trWtsthhWAXsdUu1V+gl10RBChuM4okZccJf1JXItFA2z7J2UR4cu/tRZBRFartVPhGBjK
ntLofxsaW7wwzfsinbNy30gHGShG83XDADdGUteL8PmupDcDf/MtbRIlfjEknLiuOnrM25WVajtB
3fB1pOA2jmLaaNmasza9ordaD3afJD3IWr/Zj+aevMu4zrKzwdOZqBZW1J1Qc7uog8Mn+mm+wRMm
EY0z7VFdjsZjJH9EQA0UbF1aYcshv0a/M2deKN9TdYuJ1eTKRSZdzSiRG5w75xujFMYZgo4ETlu1
Behgey1jvJiyWdOsPt7at08QMYIB6jCCAeYCAQEwZDBWMQswCQYDVQQGEwJVUzEaMBgGA1UEChMR
SW50ZWwgQ29ycG9yYXRpb24xKzApBgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3Vpbmcg
Q0EgM0ICCn9HrP0AAQAAURUwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEw
HAYJKoZIhvcNAQkFMQ8XDTEwMDkwNzIwMTY1NVowIwYJKoZIhvcNAQkEMRYEFMrXr3px3inBX2/m
xKva9c2OzDCdMA0GCSqGSIb3DQEBAQUABIIBABdR5ZmwugWEVMDIIIz8Z+rukXT4An6Hkv9QpJHn
I12p0aQJScyNB7LELZ2+l6HJAEd2FsmUNhVAD3HybMDzllft+vMcjbx4DSDUM2bnkg54iNkmE3TZ
ckriT5l+HjX/1ZMlm7+TA2sLhfDXNnJphD21eaAQXyd+O+YrN7OMYNRGMs3iS5JpYxjh3i75UD3q
D7SDWZxLd6CWzrxyDAgRMtbcYYdZC6PHO/Ura5DCNYuF6ofMonl8K7jvOrICwoIMAJfRIvjTRoDp
cX32+15YZPdad2cfn0hZOv7qGdR9ixSCF+jDmCx10zBJQJo8yIWIWuL6xJxOcZGfXD7EYxvetxsA
AAAAAAA=


--=-KzagmC3GXa+F/HUmQPr0--
