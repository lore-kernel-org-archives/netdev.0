From: Humberto Alves <hjalves@live.com>
Subject: Re: [iproute2] regression in ss output
Date: Mon, 16 Oct 2017 20:34:08 +0000
Message-ID: <AM4PR0901MB1252E2E42B84DC49651E0C07CC4F0@AM4PR0901MB1252.eurprd09.prod.outlook.com>
References: <AM4PR0901MB125261BF480B49D2BA2DF46BCC480@AM4PR0901MB1252.eurprd09.prod.outlook.com>
 <20171016092058.470f3424@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pkcs7-signature";
        micalg=sha-256; boundary="------------ms000200030902080605050008"
To: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oln040092066069.outbound.protection.outlook.com ([40.92.66.69]:52784
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752976AbdJPUeL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 16:34:11 -0400
In-Reply-To: <20171016092058.470f3424@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------ms000200030902080605050008
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

IMHO that's not ugly.
How is that a feature? Differentiating IPv4 from IPv6 sockets is a=20
feature to me!
If you want to use '*' in IPv4 and IPv6, add another column please.
Thank you

On 10/16/2017 05:20 PM, Stephen Hemminger wrote:
> On Fri, 13 Oct 2017 09:57:37 +0000
> Humberto Alves <hjalves@live.com> wrote:
>=20
>> Hi! With the last iproute2 release, ss command output does not
>> differentiate between any-address IPv4 sockets from the IPv6 ones.
>> I don't know if this is an expected behaviour, but the old output look=
s
>> more useful. Below I pasted the difference between the old behaviour a=
nd
>> the new one.
>> I am happy to send a patch if you want. Thanks
>>
>>
>> iproute2-4.12
>> -------------
>>
>> $ ss --version
>> ss utility, iproute2-ss170705
>>
>> $ ss -ntl
>> State       Recv-Q Send-Q Local Address:Port               Peer
>> Address:Port
>> LISTEN      0      100            *:587                        *:*
>>
>> LISTEN      0      100            *:110                        *:*
>>
>> LISTEN      0      100            *:143                        *:*
>>
>> LISTEN      0      128            *:80                         *:*
>>
>> LISTEN      0      128            *:2225                       *:*
>>
>> LISTEN      0      10     127.0.0.1:5010                       *:*
>>
>> LISTEN      0      128            *:20                         *:*
>>
>> LISTEN      0      128    127.0.0.1:20150                      *:*
>>
>> LISTEN      0      128            *:61719                      *:*
>>
>> LISTEN      0      100            *:25                         *:*
>>
>> LISTEN      0      3              *:1723                       *:*
>>
>> LISTEN      0      128            *:17500                      *:*
>>
>> LISTEN      0      128    127.0.0.1:17600                      *:*
>>
>> LISTEN      0      128            *:8000                       *:*
>>
>> LISTEN      0      100            *:993                        *:*
>>
>> LISTEN      0      128    127.0.0.1:17603                      *:*
>>
>> LISTEN      0      100            *:995                        *:*
>>
>> LISTEN      0      100           :::587                       :::*
>>
>> LISTEN      0      100           :::110                       :::*
>>
>> LISTEN      0      100           :::143                       :::*
>>
>> LISTEN      0      128           :::22000                     :::*
>>
>> LISTEN      0      128           :::80                        :::*
>>
>> LISTEN      0      128           :::2225                      :::*
>>
>> LISTEN      0      128           :::20                        :::*
>>
>> LISTEN      0      128          ::1:20150                     :::*
>>
>> LISTEN      0      100           :::25                        :::*
>>
>> LISTEN      0      128           :::17500                     :::*
>>
>> LISTEN      0      128           :::8384                      :::*
>>
>> LISTEN      0      100           :::993                       :::*
>>
>> LISTEN      0      100           :::995                       :::*
>>
>> iproute2-4.13
>> -------------
>>
>> $ ss --version
>> ss utility, iproute2-ss170905
>>
>> $ ss -ntl
>> State       Recv-Q Send-Q Local Address:Port               Peer
>> Address:Port
>> LISTEN      0      100            *:587                        *:*
>>
>> LISTEN      0      100            *:110                        *:*
>>
>> LISTEN      0      100            *:143                        *:*
>>
>> LISTEN      0      128            *:80                         *:*
>>
>> LISTEN      0      128            *:2225                       *:*
>>
>> LISTEN      0      10     127.0.0.1:5010                       *:*
>>
>> LISTEN      0      128            *:20                         *:*
>>
>> LISTEN      0      128    127.0.0.1:20150                      *:*
>>
>> LISTEN      0      128            *:61719                      *:*
>>
>> LISTEN      0      100            *:25                         *:*
>>
>> LISTEN      0      3              *:1723                       *:*
>>
>> LISTEN      0      128            *:17500                      *:*
>>
>> LISTEN      0      128    127.0.0.1:17600                      *:*
>>
>> LISTEN      0      128            *:8000                       *:*
>>
>> LISTEN      0      100            *:993                        *:*
>>
>> LISTEN      0      128    127.0.0.1:17603                      *:*
>>
>> LISTEN      0      100            *:995                        *:*
>>
>> LISTEN      0      100            *:587                        *:*
>>
>> LISTEN      0      100            *:110                        *:*
>>
>> LISTEN      0      100            *:143                        *:*
>>
>> LISTEN      0      128            *:22000                      *:*
>>
>> LISTEN      0      128            *:80                         *:*
>>
>> LISTEN      0      128            *:2225                       *:*
>>
>> LISTEN      0      128            *:20                         *:*
>>
>> LISTEN      0      128        [::1]:20150                      *:*
>>
>> LISTEN      0      100            *:25                         *:*
>>
>> LISTEN      0      128            *:17500                      *:*
>>
>> LISTEN      0      128            *:8384                       *:*
>>
>> LISTEN      0      100            *:993                        *:*
>>
>> LISTEN      0      100            *:995                        *:*
>=20
> All changes are not regressions.
>=20
> Yes it was intentional because the outputing  [::]:20 looked ugly and u=
sing * makes IPv4 and IPv6
> look the same.
>=20


--------------ms000200030902080605050008
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIAGCSqGSIb3DQEHAqCAMIACAQExDzANBglghkgBZQMEAgEFADCABgkqhkiG9w0BBwEAAKCC
CxkwggUrMIIEE6ADAgECAhAieTCr/hihj2HgS0mCvAKIMA0GCSqGSIb3DQEBCwUAMIGXMQsw
CQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxm
b3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGltaXRlZDE9MDsGA1UEAxM0Q09NT0RPIFJTQSBD
bGllbnQgQXV0aGVudGljYXRpb24gYW5kIFNlY3VyZSBFbWFpbCBDQTAeFw0xNzEwMTIwMDAw
MDBaFw0xODEwMTIyMzU5NTlaMCExHzAdBgkqhkiG9w0BCQEWEGhqYWx2ZXNAbGl2ZS5jb20w
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC47BWTYxsQTz6rcr+3gx9YyXyBg4/K
/bNyEM0H7idMRlUUpXMa0dSj7UEvZoSeQjHBjujDSDK1+HS/x+9TpvnZUUz5Y4ixordZALH5
WCJ2hxYlFpuo6SVryj/nw57ABMsk7pRrVWAjcDyK6e9EztuKCQKB6qXM8Ew0Ftbotm8xsW8Q
Er6PlUeK/M99v8fsD1y9HFl0TugAY7PtcYL0dVoon/E3xfq4W65ILFHxpBxCnd/XRzRd0aBS
eusMDLx1Hrsl7bLhsSJ7yhpXyiotjf2dYqZXTeavs5ZeCF7Zahv81wd5P9bX5AgTU6jtQdtE
kmCgLx1Ixwx+QRdA57CUpxlhAgMBAAGjggHmMIIB4jAfBgNVHSMEGDAWgBSCr2yM+MX+lmF8
6B89K3FIXsSLwDAdBgNVHQ4EFgQUlJKtuPmHGZC7hs9Dx0qHHfwvuGIwDgYDVR0PAQH/BAQD
AgWgMAwGA1UdEwEB/wQCMAAwIAYDVR0lBBkwFwYIKwYBBQUHAwQGCysGAQQBsjEBAwUCMBEG
CWCGSAGG+EIBAQQEAwIFIDBGBgNVHSAEPzA9MDsGDCsGAQQBsjEBAgEBATArMCkGCCsGAQUF
BwIBFh1odHRwczovL3NlY3VyZS5jb21vZG8ubmV0L0NQUzBaBgNVHR8EUzBRME+gTaBLhklo
dHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9DT01PRE9SU0FDbGllbnRBdXRoZW50aWNhdGlvbmFu
ZFNlY3VyZUVtYWlsQ0EuY3JsMIGLBggrBgEFBQcBAQR/MH0wVQYIKwYBBQUHMAKGSWh0dHA6
Ly9jcnQuY29tb2RvY2EuY29tL0NPTU9ET1JTQUNsaWVudEF1dGhlbnRpY2F0aW9uYW5kU2Vj
dXJlRW1haWxDQS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTAb
BgNVHREEFDASgRBoamFsdmVzQGxpdmUuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCKA78qsNtR
YOtq5rVoixJObIDvlzwM+mYhC58hCkHxAwGzL79Guhj40/yEbieO+24SAdb+jBr+wmo1cJ8c
Piaigr3lyBW7rwDs6qRSG/3JejzuOkx7xEEGxrkerFJUGE7nbE7g6mlh1MxrylOtNZC7wrur
KqGPakZzkuIy8GobcpVIDTfmbm7bG5H4smnor0RDeCYvSLmMn+GO7KKjXK66bzMx2XTEebIj
SO8b0JILx214tnkcWSE3lzMTUJNxc+60HvgLvNX/2vxtosI5GLhwCtD+0CEAek2VBMqjUjcH
aw6t+wPu54DANatFRq/LeRnQSwkvUwL66exMuSmovls4MIIF5jCCA86gAwIBAgIQapvhODv/
K2ufAdXZuKdSVjANBgkqhkiG9w0BAQwFADCBhTELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdy
ZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09NT0RPIENB
IExpbWl0ZWQxKzApBgNVBAMTIkNPTU9ETyBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkw
HhcNMTMwMTEwMDAwMDAwWhcNMjgwMTA5MjM1OTU5WjCBlzELMAkGA1UEBhMCR0IxGzAZBgNV
BAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEaMBgGA1UEChMRQ09N
T0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0EgQ2xpZW50IEF1dGhlbnRpY2F0
aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
AQC+s55XrCh2dUAWxzgDmNPGGHYhUPMleQtMtaDRfTpYPpynMS6n9jR22YRq2tA9NEjk6vW7
rN/5sYFLIP1of3l0NKZ6fLWfF2VgJ5cijKYy/qlAckY1wgOkUMgzKlWlVJGyK+UlNEQ1/5Er
CsHq9x9aU/x1KwTdF/LCrT03Rl/FwFrf1XTCwa2QZYL55AqLPikFlgqOtzk06kb2qvGlnHJv
ijjI03BOrNpo+kZGpcHsgyO1/u1OZTaOo8wvEU17VVeP1cHWse9tGKTDyUGg2hJZjrqck39U
Im/nKbpDSZ0JsMoIw/JtOOg0JC56VzQgBo7ictReTQE5LFLG3yQK+xS1AgMBAAGjggE8MIIB
ODAfBgNVHSMEGDAWgBS7r34CPfqm8TyEjq3uOJjs2TIy1DAdBgNVHQ4EFgQUgq9sjPjF/pZh
fOgfPStxSF7Ei8AwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEQYDVR0g
BAowCDAGBgRVHSAAMEwGA1UdHwRFMEMwQaA/oD2GO2h0dHA6Ly9jcmwuY29tb2RvY2EuY29t
L0NPTU9ET1JTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHEGCCsGAQUFBwEBBGUwYzA7
BggrBgEFBQcwAoYvaHR0cDovL2NydC5jb21vZG9jYS5jb20vQ09NT0RPUlNBQWRkVHJ1c3RD
QS5jcnQwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0B
AQwFAAOCAgEAeFyygSg0TzzuX1bOn5dW7I+iaxf28/ZJCAbU2C81zd9A/tNx4+jsQgwRGiHj
ZrAYayZrrm78hOx7aEpkfNPQIHGG6Fvq3EzWf/Lvx7/hk6zSPwIal9v5IkDcZoFD7f3iT7Pd
kHJY9B51csvU50rxpEg1OyOT8fk2zvvPBuM4qQNqbGWlnhMpIMwpWZT89RY0wpJO+2V6eXEG
GHsROs3njeP9DqqqAJaBa4wBeKOdGCWn1/Jp2oY6dyNmNppI4ZNMUH4Tam85S1j6E95u4+1N
uru84OrMIzqvISE2HN/56ebTOWlcrurffade2022O/tUU1gb4jfWCcyvB8czm12FgX/y/lRj
mDbEA08QJNB2729Y+io1IYO3ztveBdvUCIYZojTq/OCR6MvnzS6X72HP0PRLRTiOSEmIDsS5
N5w/8IW1Hva5hEFy6fDAfd9yI+O+IMMAj1KcL/Zo9jzJ16HO5m60ttl1Enk8MQkz/W3JlHae
I5iKFn4UJu1/cP2YHXYPiWf2JyBzsLBrGk1II+3yL8aorYew6CQvdVifC3HtwlSam9V1niiC
fOBe2C12TdKGu05LWIA3ZkFcWJGaNXOZ6Ggyh/TqvXG5v7zmEVDNXFnHn9tFpMpOUvxhcsjy
cBtH0dZ0WrNw6gH+HF8TIhCnH3+zzWuDN0Rk6h9KVkfKehIxggQ1MIIEMQIBATCBrDCBlzEL
MAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
Zm9yZDEaMBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0Eg
Q2xpZW50IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECECJ5MKv+GKGPYeBL
SYK8AogwDQYJYIZIAWUDBAIBBQCgggJZMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
KoZIhvcNAQkFMQ8XDTE3MTAxNjIwMzQwNVowLwYJKoZIhvcNAQkEMSIEIHKrT/pfjEzwmtf7
otW60lXT+punyRSjSAZ7Wy5LBhE0MGwGCSqGSIb3DQEJDzFfMF0wCwYJYIZIAWUDBAEqMAsG
CWCGSAFlAwQBAjAKBggqhkiG9w0DBzAOBggqhkiG9w0DAgICAIAwDQYIKoZIhvcNAwICAUAw
BwYFKw4DAgcwDQYIKoZIhvcNAwICASgwgb0GCSsGAQQBgjcQBDGBrzCBrDCBlzELMAkGA1UE
BhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEa
MBgGA1UEChMRQ09NT0RPIENBIExpbWl0ZWQxPTA7BgNVBAMTNENPTU9ETyBSU0EgQ2xpZW50
IEF1dGhlbnRpY2F0aW9uIGFuZCBTZWN1cmUgRW1haWwgQ0ECECJ5MKv+GKGPYeBLSYK8Aogw
gb8GCyqGSIb3DQEJEAILMYGvoIGsMIGXMQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRl
ciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRowGAYDVQQKExFDT01PRE8gQ0EgTGlt
aXRlZDE9MDsGA1UEAxM0Q09NT0RPIFJTQSBDbGllbnQgQXV0aGVudGljYXRpb24gYW5kIFNl
Y3VyZSBFbWFpbCBDQQIQInkwq/4YoY9h4EtJgrwCiDANBgkqhkiG9w0BAQEFAASCAQBpp3EY
ZFOIG7DHg4Cjr6Yablzayb4fFnyTeXNx1PI6d6jvL7LIiPQ6lY+3MVhF5ZyuJBexvyfWV63Z
/wAr9gise0L54nbqDYrfdADxOtthbPPT+rOf8Jcp2eawkrqTNTfm2k6WQSjXTcS7HF4HK7+y
VswPIKUc4JmNxM/2cqcCZAsEh/I9qJPDzLJvxBxWtAgGMW7CMl3fpo7Jni7dCH7JJ9b4JvtR
u5O5Uz2wt4xX9tCt2cYjcSO1waoCY/Ray8usjNQcNiCFXUznLSHn5nm27o4qPMNv9Kj2/vFV
Z7HKDyePRWeHSxv+M72+tVlVmcqWzPbJiSQgSR9xVclVeg/7AAAAAAAA

--------------ms000200030902080605050008--
