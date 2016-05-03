From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: Re: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control flags to ip l2tp add tunnel
Date: Tue, 3 May 2016 10:40:44 +0800
Message-ID: <D9A75A07-D84B-4F21-A4F0-2CA2D7AD3AE6@gmail.com>
References: <CAEwTi7SkMrgxpPi-EuC2UDiwv7L0-vdRAhtdAYLgnbnw5H-Eig@mail.gmail.com> <FD67CA88-0731-4DD7-AC78-5A4B922810D6@gmail.com> <AFE6B2C1-93B5-4782-870D-2C6C81BF6F52@gmail.com> <CAEwTi7SyKKh4de6TKYiuypWfOhzOCeD6k2uTLUfCmzQmvsNHWw@mail.gmail.com> <20160502151910.3a1f6f3d@xeon-e3>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_5B7AC34F-DC03-4EB0-B06B-63AAFC747BF0"; protocol="application/pkcs7-signature"; micalg=sha1
Cc: James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34813 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbcECCkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 22:40:53 -0400
Received: by mail-pf0-f170.google.com with SMTP id y69so3420493pfb.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 19:40:53 -0700 (PDT)
In-Reply-To: <20160502151910.3a1f6f3d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_5B7AC34F-DC03-4EB0-B06B-63AAFC747BF0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=gb2312

Thanks a lot.

I feel it excited to contribute to the development of kernel. I=A1=AFll =
do=20
better next time.

> =D4=DA 2016=C4=EA5=D4=C23=C8=D5=A3=AC06:19=A3=ACStephen Hemminger =
<stephen@networkplumber.org> =D0=B4=B5=C0=A3=BA
>=20
> On Thu, 28 Apr 2016 15:50:47 +0100
> James Chapman <jchapman@katalix.com> wrote:
>=20
>> Yes, that looks like the problem.
>>=20
>> The comments in l2tp.h which indicate that the csum attributes are u8
>> values are wrong. Code in net/l2tp/l2tp_netlink.c accesses these
>> attributes using nla_get_flag().
>>=20
>> Please submit a patch to fix l2tp_tunnel_sock_create(). Include good
>> change notes and your signed-off-by tag so that it gets reviewed. See
>> Documentation/SubmittingPatches if you haven't submitted a kernel
>> patch here before.
>=20
> Thank you for fixing this. James is is correct.
> Please format the patch according to the submission guidelines.
> For example, checkpatch complains about current patch.
>=20
> ERROR: code indent should use tabs where possible
> #156: FILE: net/l2tp/l2tp_core.c:1379:
> +                         ! cfg->udp6_zero_tx_checksums;$
>=20
> WARNING: please, no spaces at the start of a line
> #156: FILE: net/l2tp/l2tp_core.c:1379:
> +                         ! cfg->udp6_zero_tx_checksums;$
>=20
> ERROR: space prohibited after that '!' (ctx:ExW)
> #156: FILE: net/l2tp/l2tp_core.c:1379:
> +                         ! cfg->udp6_zero_tx_checksums;
>                          ^
>=20
> ERROR: code indent should use tabs where possible
> #159: FILE: net/l2tp/l2tp_core.c:1381:
> +                         ! cfg->udp6_zero_rx_checksums;$
>=20
> WARNING: please, no spaces at the start of a line
> #159: FILE: net/l2tp/l2tp_core.c:1381:
> +                         ! cfg->udp6_zero_rx_checksums;$
>=20
> ERROR: space prohibited after that '!' (ctx:ExW)
> #159: FILE: net/l2tp/l2tp_core.c:1381:
> +                         ! cfg->udp6_zero_rx_checksums;
>                          ^
>=20
> ERROR: Missing Signed-off-by: line(s)
>=20
>=20
> I am sorry that maintainers may seem like picky teachers in school
> always putting redline around spelling errors, but this is how we work =
to teach
> others how to follow the process.
>=20


--Apple-Mail=_5B7AC34F-DC03-4EB0-B06B-63AAFC747BF0
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIMdTCCBjQw
ggQcoAMCAQICAR4wDQYJKoZIhvcNAQEFBQAwfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0
Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxKTAn
BgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MB4XDTA3MTAyNDIxMDE1NVoX
DTE3MTAyNDIxMDE1NVowgYwxCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFy
dENvbSBDbGFzcyAxIFByaW1hcnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQTCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAMcJg8zOLdgasSmkLhOrlr6KMoOMpohBllVHrdRvEg/q6r8jR+EK
75xCGhR8ToREoqe7zM9/UnC6TS2y9UKTpT1v7RSMzR0t6ndl0TWBuUr/UXBhPk+Kmy7bI4yW4urC
+y7P3/1/X7U8ocb8VpH/Clt+4iq7nirMcNh6qJR+xjOhV+VHzQMALuGYn5KZmc1NbJQYclsGkDxD
z2UbFqE2+6vIZoL+jb9x4Pa5gNf1TwSDkOkikZB1xtB4ZqtXThaABSONdfmv/Z1pua3FYxnCFmdr
/+N2JLKutIxMYqQOJebr/f/h5t95m4JgrM3Y/w7YX9d7YAL9jvN4SydHsU6n65cCAwEAAaOCAa0w
ggGpMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMB0GA1UdDgQWBBRTcu2SnODaywFc
fH6WNU7y1LhRgjAfBgNVHSMEGDAWgBROC+8apEBbpRdphzDKNGhD0EGu8jBmBggrBgEFBQcBAQRa
MFgwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9jYTAtBggrBgEFBQcwAoYh
aHR0cDovL3d3dy5zdGFydHNzbC5jb20vc2ZzY2EuY3J0MFsGA1UdHwRUMFIwJ6AloCOGIWh0dHA6
Ly93d3cuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDAnoCWgI4YhaHR0cDovL2NybC5zdGFydHNzbC5j
b20vc2ZzY2EuY3JsMIGABgNVHSAEeTB3MHUGCysGAQQBgbU3AQIBMGYwLgYIKwYBBQUHAgEWImh0
dHA6Ly93d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwNAYIKwYBBQUHAgEWKGh0dHA6Ly93d3cu
c3RhcnRzc2wuY29tL2ludGVybWVkaWF0ZS5wZGYwDQYJKoZIhvcNAQEFBQADggIBAAqDCH14qywG
XLhjjF6uHLkjd02hcdh9hrw+VUsv+q1eeQWB21jWj3kJ96AUlPCoEGZ/ynJNScWy6QMVQjbbMXlt
UfO4n4bGGdKo3awPWp61tjAFgraLJgDk+DsSvUD6EowjMTNx25GQgyYJ5RPIzKKR9tQW8gGK+2+R
HxkUCTbYFnL6kl8Ch507rUdPPipJ9CgJFws3kDS3gOS5WFMxcjO5DwKfKSETEPrHh7p5shuuNktv
sv6hxHTLhiMKX893gxdT3XLS9OKmCv87vkINQcNEcIIoFWbP9HORz9v3vQwR4e3ksLc2JZOAFK+s
sS5XMEoznzpihEP0PLc4dCBYjbvSD7kxgDwZ+Aj8Q9PkbvE9sIPP7ON0fz095HdThKjiVJe6vofq
+n6b1NBc8XdrQvBmunwxD5nvtTW4vtN6VY7mUCmxsCieuoBJ9OlqmsVWQvifIYf40dJPZkk9YgGT
zWLpXDSfLSplbY2LL9C9U0ptvjcDjefLTvqSFc7tw1sEhF0n/qpA2r0GpvkLRDmcSwVyPvmjFBGq
Up/pNy8ZuPGQmHwFi2/14+xeSUDG2bwnsYJQG2EdJCB6luQ57GEnTA/yKZSTKI8dDQa8Sd3zfXb1
9mOgSF0bBdXbuKhEpuP9wirslFe6fQ1t5j5R0xi72MZ8ikMu1RQZKCyDbMwazlHiMIIGOTCCBSGg
AwIBAgIDDv9GMA0GCSqGSIb3DQEBCwUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYG
A1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0EwHhcN
MTUwODExMDk1NjA4WhcNMTYwODEyMDIwODUwWjBOMSIwIAYDVQQDDBlzaGFua2Vyd2FuZ21pYW9A
Z21haWwuY29tMSgwJgYJKoZIhvcNAQkBFhlzaGFua2Vyd2FuZ21pYW9AZ21haWwuY29tMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwB9ZB/Au3Wnciv7VW8oKtPPVbaD7zFAhbWDFrq6N
0mmEBg5xqbEvmsO3KwKmXe9c7C5cxwIXC8XSAPOQCPoWC0mXmCM1cacWnDonHa+pIgEmreoUmwyD
q4x00vODejFtF7oUFeteDwBKxAxeF8PkyCINwGVLloJFJCctDL3+3XZ+H2ZTluRKil/5TvO1hiEt
V7N9kI0K0gJhTnLDG7n+YdWHHCrpBbdJ3Te4eQqpRHegPSEz+kbXDPgCVHI86ze0A11I0mDWOVN/
4Fxw/0voecL2tuh4NHsZ9H/TPZw7AWLKdzlv/vJUOxHqky2gRdaIlheW5uzOvIt6DK4DTi3n9wID
AQABo4IC3zCCAtswCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAwHQYDVR0lBBYwFAYIKwYBBQUHAwIG
CCsGAQUFBwMEMB0GA1UdDgQWBBRrXUiEjuNWrWV2DoY2Y8YuFBl0qzAfBgNVHSMEGDAWgBRTcu2S
nODaywFcfH6WNU7y1LhRgjAkBgNVHREEHTAbgRlzaGFua2Vyd2FuZ21pYW9AZ21haWwuY29tMIIB
TAYDVR0gBIIBQzCCAT8wggE7BgsrBgEEAYG1NwECAzCCASowLgYIKwYBBQUHAgEWImh0dHA6Ly93
d3cuc3RhcnRzc2wuY29tL3BvbGljeS5wZGYwgfcGCCsGAQUFBwICMIHqMCcWIFN0YXJ0Q29tIENl
cnRpZmljYXRpb24gQXV0aG9yaXR5MAMCAQEagb5UaGlzIGNlcnRpZmljYXRlIHdhcyBpc3N1ZWQg
YWNjb3JkaW5nIHRvIHRoZSBDbGFzcyAxIFZhbGlkYXRpb24gcmVxdWlyZW1lbnRzIG9mIHRoZSBT
dGFydENvbSBDQSBwb2xpY3ksIHJlbGlhbmNlIG9ubHkgZm9yIHRoZSBpbnRlbmRlZCBwdXJwb3Nl
IGluIGNvbXBsaWFuY2Ugb2YgdGhlIHJlbHlpbmcgcGFydHkgb2JsaWdhdGlvbnMuMDYGA1UdHwQv
MC0wK6ApoCeGJWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydHUxLWNybC5jcmwwgY4GCCsGAQUF
BwEBBIGBMH8wOQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLnN0YXJ0c3NsLmNvbS9zdWIvY2xhc3Mx
L2NsaWVudC9jYTBCBggrBgEFBQcwAoY2aHR0cDovL2FpYS5zdGFydHNzbC5jb20vY2VydHMvc3Vi
LmNsYXNzMS5jbGllbnQuY2EuY3J0MCMGA1UdEgQcMBqGGGh0dHA6Ly93d3cuc3RhcnRzc2wuY29t
LzANBgkqhkiG9w0BAQsFAAOCAQEAe5XhL57HyMjbkRhKggwhTv+Ccl2C16lW37jwl8pDDIEy4xZq
kt0J2T4wAPWOnRjWfMiBC5Y4QqT9IUlWZnE4BfsgbmRSrbXKfafLJkXBJNn+sVbpf6YsKLNoaZwC
Bb+7W2sSs7SIq1v3m8A+kR/VmisqGakqy0LlFrwqddDRmMweuVY4RDYbJi+LQfiRlorhzobOnYKc
/QEiCpbLru5vuKVDF3GoqhFBxuFIUPMtJ9Rzqjtp8PSg8Dp2TTzpEBumc2oCxc7vmsYuNT0duGR+
9k6XIJJEDFvJrUYZM1RnSuyF7mmQi+LTPmlHHCp8u+7PZJaa2rSI1+Oup2lJqD56pDGCA28wggNr
AgEBMIGUMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMi
U2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xh
c3MgMSBQcmltYXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw7/RjAJBgUrDgMCGgUAoIIBrzAY
BgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNjA1MDMwMjQwNDVaMCMG
CSqGSIb3DQEJBDEWBBSCFisVRnW9PfVOGH6USHzZsJQ9SzCBpQYJKwYBBAGCNxAEMYGXMIGUMIGM
MQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERp
Z2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMSBQcmlt
YXJ5IEludGVybWVkaWF0ZSBDbGllbnQgQ0ECAw7/RjCBpwYLKoZIhvcNAQkQAgsxgZeggZQwgYwx
CzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSswKQYDVQQLEyJTZWN1cmUgRGln
aXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMTgwNgYDVQQDEy9TdGFydENvbSBDbGFzcyAxIFByaW1h
cnkgSW50ZXJtZWRpYXRlIENsaWVudCBDQQIDDv9GMA0GCSqGSIb3DQEBAQUABIIBALPFX7tPRMnu
LKB8WzZfk0XqY/jOM0AQoWkH77wpXus8cUjxteAWRQLJvxqXWNe3iTU3CH1BaqwXK+KBzqWHBen1
SUFoNgHEB2ItnBFUeAZaspWElsbTgDbTBJZL05lCdOnEm/CukYadiHf81ThV9UKi1Pc//it5sjNc
r12dvV3/RsdzOveXFLVtNHEBe0xkVBn2qqcThIlyRPaS9RPW7zU8IKwmEV7h2bw0yHcn95NXFO7d
3ERV4i0aGOMSdaJuKrlG1x65qK5JeMs7IZEMdx3PW9aMNtuOsM06rBZWNoSAZJi0+eE+33L6Ch8C
m9f+khtsxb9yInMGnXEuq6S1C7gAAAAAAAA=
--Apple-Mail=_5B7AC34F-DC03-4EB0-B06B-63AAFC747BF0--
