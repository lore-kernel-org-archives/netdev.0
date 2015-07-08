From: Austin S Hemmelgarn <ahferroin7@gmail.com>
Subject: Re: [PATCH v2] add stealth mode
Date: Wed, 08 Jul 2015 09:32:56 -0400
Message-ID: <559D2688.5020302@gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com> <21611.1436179798@turing-police.cc.vt.edu> <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha1; boundary="------------ms080309030208030408040004"
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>, Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFnufp3xP3xjd8zy0uLKEGgbBAb0motLva=f1EbMJCfcKG=Y-w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a cryptographically signed message in MIME format.

--------------ms080309030208030408040004
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable

On 2015-07-06 15:44, Matteo Croce wrote:
> 2015-07-06 12:49 GMT+02:00  <Valdis.Kletnieks@vt.edu>:
>> On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
>>> Add option to disable any reply not related to a listening socket,
>>> like RST/ACK for TCP and ICMP Port-Unreachable for UDP.
>>> Also disables ICMP replies to echo request and timestamp.
>>> The stealth mode can be enabled selectively for a single interface.
>>
>> A few notes.....
>>
>> 2) You *do* realize that this isn't anywhere near sufficient in order
>> to actually make your machine "invisible", right?  (Hint: What *other*=

>> packets can be sent to a machine to provoke a response?)
>
> Other than ICMP, UDP and TCP excluding open TCP/UDP ports?
>
Just to name a few that I know of off the top of my head:
1. IP packets with any protocol number not supported by your current=20
kernel (these return a special ICMP message).
2. SCTP INIT and COOKIE_ECHO chunks when you have SCTP enabled in the=20
kernel.
3. Theoretically, some IGMP messages.
4. NDP messages.
5. ARP queries looking for the machine's IP addresses.
6. Certain odd flag combinations on single TCP packets (check the=20
documentation for Nmap for more info regarding these), which I believe=20
(although I may be reading the code wrong) you aren't accounting for.
7. DAD queries.
8. ICMP address mask queries (which you also don't appear to account for)=
=2E

This is by no means an exhaustive list, but all of them really should be =

addressed if you want to do this properly.



--------------ms080309030208030408040004
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGuDCC
BrQwggScoAMCAQICAxBuVTANBgkqhkiG9w0BAQ0FADB5MRAwDgYDVQQKEwdSb290IENBMR4w
HAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmlu
ZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZzAeFw0xNTAz
MjUxOTM0MzhaFw0xNTA5MjExOTM0MzhaMGMxGDAWBgNVBAMTD0NBY2VydCBXb1QgVXNlcjEj
MCEGCSqGSIb3DQEJARYUYWhmZXJyb2luN0BnbWFpbC5jb20xIjAgBgkqhkiG9w0BCQEWE2Fo
ZW1tZWxnQG9oaW9ndC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCdD/zW
2rRAFCLnDfXpWxU1+ODqRVUgzHvrRO7ADUxRo1CBDc3JSX5TIW2OGmQ3DAKGOACp8Z0sgxMc
B05tzAZ/M7m4jajVrwwdVCdrwVGxTdAai7Kwg4ZCVfyMVhcwo8R2eW3QahBx34G0RKumK9sZ
ZQSQ+zULAzpY6uz7T1sAk/erMoivRXF6u8WvOsLkOD1F/Xyv1ZccSUG5YeDgZgc0nZUBvyIp
zXSHjgWerFkrxEM3y2z/Ff3eL1sgGYecV/I1F+I5S01V7Kclt/qRW10c/4JEGRcI1FmrJBPu
BtMYPbg/3Y9LZROYN+mVIFxZxOfrmjfFZ96xt/TaMXo8vcEKtWcNEjhGBjEbfMUEm4aq8ygQ
4MuEcpJc8DJCHBkg2KBk13DkbU2qNepTD6Uip1C+g+KMr0nd6KOJqSH27ZuNY4xqV4hIxFHp
ex0zY7mq6fV2o6sKBGQzRdI20FDYmNjsLJwjH6qJ8laxFphZnPRpBThmu0AjuBWE72GnI1oA
aO+bs92MQGJernt7hByCnDO82W/ykbVz+Ge3Sax8NY0m2Xdvp6WFDY/PjD9CdaJ9nwQGsUSa
N54lrZ2qMTeCI9Vauwf6U69BA42xgk65VvxvTNqji+tZ4aZbarZ7el2/QDHOb/rRwlCFplS/
z4l1f1nOrE6bnDl5RBJyW3zi74P6GwIDAQABo4IBWTCCAVUwDAYDVR0TAQH/BAIwADBWBglg
hkgBhvhCAQ0ESRZHVG8gZ2V0IHlvdXIgb3duIGNlcnRpZmljYXRlIGZvciBGUkVFIGhlYWQg
b3ZlciB0byBodHRwOi8vd3d3LkNBY2VydC5vcmcwDgYDVR0PAQH/BAQDAgOoMEAGA1UdJQQ5
MDcGCCsGAQUFBwMEBggrBgEFBQcDAgYKKwYBBAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4
QgQBMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9y
ZzAxBgNVHR8EKjAoMCagJKAihiBodHRwOi8vY3JsLmNhY2VydC5vcmcvcmV2b2tlLmNybDA0
BgNVHREELTArgRRhaGZlcnJvaW43QGdtYWlsLmNvbYETYWhlbW1lbGdAb2hpb2d0LmNvbTAN
BgkqhkiG9w0BAQ0FAAOCAgEAGvl7xb42JMRH5D/vCIDYvFY3dR2FPd5kmOqpKU/fvQ8ovmJa
p5N/FDrsCL+YdslxPY+AAn78PYmL5pFHTdRadT++07DPIMtQyy2qd+XRmz6zP8Il7vGcEDmO
WmMLYMq4xV9s/N7t7JJp6ftdIYUcoTVChUgilDaRWMLidtslCdRsBVfUjPb1bF5Ua31diKDP
e0M9/e2CU36rbcTtiNCXhptMigzuL3zJXUf2B9jyUV8pnqNEQH36fqJ7YTBLcpq3aYa2XbAH
Hgx9GehJBIqwspDmhPCFZ/QmqUXCkt+XfvinQ2NzKR6P3+OdYbwqzVX8BdMeojh7Ig8x/nIx
mQ+/ufstL1ZYp0bg13fyK/hPYSIBpayaC76vzWovkIm70DIDRIFLi20p/qTd7rfDYy831Hjm
+lDdCECF9bIXEWFk33kA97dgQIMbf5chEmlFg8S0e4iw7LMjvRqMX3eCD8GJ2+oqyZUwzZxy
S0Mx+rBld5rrN7LsXwZ671HsGqNeYbYeU25e7t7/Gcc6Bd/kPfA+adEuUGFcvUKH3trDYqNq
6mOkAd8WO/mQadlc3ztS++XDMhmIpfBre9MPAr6usqf+wc+R8Nk9KLK39kEgrqVfzc/fgf8L
MaD4rHnusdg4gca6Yi+kNrm99anw7SwaBrBvULYBp7ixNRUhaYiNW4YjTrYxggShMIIEnQIB
ATCBgDB5MRAwDgYDVQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5v
cmcxIjAgBgNVBAMTGUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEW
EnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5VMAkGBSsOAwIaBQCgggH1MBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDcwODEzMzI1NlowIwYJKoZIhvcNAQkE
MRYEFK0BnSywfwJBDbEyLApdi+PV3HGNMGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEq
MAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwIC
AUAwBwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgZEGCSsGAQQBgjcQBDGBgzCBgDB5MRAwDgYD
VQQKEwdSb290IENBMR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMT
GUNBIENlcnQgU2lnbmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2Fj
ZXJ0Lm9yZwIDEG5VMIGTBgsqhkiG9w0BCRACCzGBg6CBgDB5MRAwDgYDVQQKEwdSb290IENB
MR4wHAYDVQQLExVodHRwOi8vd3d3LmNhY2VydC5vcmcxIjAgBgNVBAMTGUNBIENlcnQgU2ln
bmluZyBBdXRob3JpdHkxITAfBgkqhkiG9w0BCQEWEnN1cHBvcnRAY2FjZXJ0Lm9yZwIDEG5V
MA0GCSqGSIb3DQEBAQUABIICAHIqgPkgM0XMMMK3yXBkyCPLee9tf+M/7HtDiGrD8q/F0uua
i69p/OVgc42plbxb0Mtp3iGj1I7E+wCo9hjsJK30wWxMsbuU8mY8inK02mBWSvwW5pRRCMdw
qHYT9plyPCvesU1MWxSWHfi0sgLYqVvbDM/vTKmAb0zyc/uqS86+sy9jYHoKHWUv9bHg1m1L
1/Px2w41dsApqP9+h7SCKqoSKQ5AoyFTIQFJ82JgSGRV7h32e91/Hoy1Z7xq0kN92n/sbNpK
3h8RcOv0N7aYHt+BLXmAQ7zticE+Cd4UfWJgXVO22FDHR7/TMssHy+ayO/jPsD/Wqr+woxPB
B7qn9b1KL0Va+Lgz9Jo/iPbS6UK0khUEIaikn+c4iPEvhpKHP9fDEC7b7uPpidaNqDmNdKUx
JhAkJ6l8NIosObL/pjaxZXVvw3VCRX10CxP/pOMwlTkeioSQOHIQBRdiuv7VWABOWYPe0Pnu
KikxcMeGmN1QRYcQatxUu7TLphM69c5SO3A+JL/dIemFG533GAZJfDAXwGuiXPCWXoKJtx6C
rJSQ17W5MCdGg8feOoAMlDFFzdNTZ75ABmAAUbLPQEqPqpEmMdRSqT4ussrPwzy5StjqDI5w
WPAxwccBijIrbcM62mWNdhjc8hCOE02QyO5oNkrDxwA6n0H2gY0u1AVA4LHRAAAAAAAA
--------------ms080309030208030408040004--
