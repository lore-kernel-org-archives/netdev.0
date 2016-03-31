From: "Varlese, Marco" <marco.varlese@intel.com>
Subject: RE: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and
 get_prefix() error messages
Date: Thu, 31 Mar 2016 08:04:30 +0000
Message-ID: <C4896FB061E7DE4AAC93031BDCA044B11A218701@IRSMSX108.ger.corp.intel.com>
References: <C4896FB061E7DE4AAC93031BDCA044B11A2146FF@IRSMSX108.ger.corp.intel.com>
 <20160330165420.36f98115@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/x-pkcs7-signature";
	micalg=SHA1; boundary="----=_NextPart_000_001E_01D18B2C.5559B7A0"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"Szczerbik, PrzemyslawX" <przemyslawx.szczerbik@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30585 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753902AbcCaIEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 04:04:35 -0400
In-Reply-To: <20160330165420.36f98115@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_NextPart_000_001E_01D18B2C.5559B7A0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Thursday, March 31, 2016 12:54 AM
> To: Varlese, Marco <marco.varlese@intel.com>
> Cc: netdev@vger.kernel.org; davem@davemloft.net; Jiri Pirko
<jiri@resnulli.us>;
> John Fastabend <john.fastabend@gmail.com>; jhs@mojatatu.com; Szczerbik,
> PrzemyslawX <przemyslawx.szczerbik@intel.com>
> Subject: Re: [PATCH iproute2 v1 1/1] lib/utils: fix get_addr() and
get_prefix()
> error messages
> 
> On Tue, 22 Mar 2016 13:02:02 +0000
> "Varlese, Marco" <marco.varlese@intel.com> wrote:
> 
> > An attempt to add invalid address to interface would print "???" string
> > instead of the address family name.
> >
> > For example:
> > $ ip address add 256.10.166.1/24 dev ens8
> > Error: ??? prefix is expected rather than "256.10.166.1/24".
> >
> > $ ip neighbor add proxy 2001:db8::g dev ens8
> > Error: ??? address is expected rather than "2001:db8::g".
> >
> > With this patch the output will look like:
> > $ ip address add 256.10.166.1/24 dev ens8
> > Error: inet prefix is expected rather than "256.10.166.1/24".
> >
> > $ ip neighbor add proxy 2001:db8::g dev ens8
> > Error: inet6 address is expected rather than "2001:db8::g".
> >
> > Signed-off-by: Przemyslaw Szczerbik <przemyslawx.szczerbik@intel.com>
> > Signed-off-by: Marco Varlese <marco.varlese@intel.com>
> > ---
> > lib/utils.c | 4 ++--
> > 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> If you look at git, I already applied this by manual fix.

Thanks, I didn't see your other email. Thank you for your help!

------=_NextPart_000_001E_01D18B2C.5559B7A0
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

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
BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwNgYDVR0lBC8wLQYIKwYBBQUHAwQGCisGAQQBgjcK
AwQGCisGAQQBgjcKAwwGCSsGAQQBgjcVBTAXBgNVHSAEEDAOMAwGCiqGSIb4TQEFAWkwSQYDVR0f
BEIwQDA+oDygOoY4aHR0cDovL2NybC50cnVzdC1wcm92aWRlci5jb20vQWRkVHJ1c3RFeHRlcm5h
bENBUm9vdC5jcmwwOgYIKwYBBQUHAQEELjAsMCoGCCsGAQUFBzABhh5odHRwOi8vb2NzcC50cnVz
dC1wcm92aWRlci5jb20wNQYDVR0eBC4wLKAqMAuBCWludGVsLmNvbTAboBkGCisGAQQBgjcUAgOg
CwwJaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQApws2j/ZKjUmeiLwbtblDoVI+rV+bIpbex
IN/Vqa/IeSMSB3bmfswpEcYSZHHGjOI8qlyZt9dhT4nSDnrScKjmA8XvxZ3tmbNyYJybVQUV8jF/
DpADX1tGlMLxswxpJISXzLf0+DBr4cQ2ag9mwzrcN1nrOIOc+pxJtx9izyp3+bl3baulerkgZVS1
fotftH+FJLD/ex8BOcEuCIm2KVXJjs4YaZgoIBLYjTiK29JLVa15xdO305kPI1uXsu05sGuAwuFm
Sklb6k5H1/eHlUbZLm4qQDtOH00L0ShJx3BAIAjD5RYptJDQiyPZQUvt8cq+apYpVMv3yxHO8jex
40LgMIIFejCCBGKgAwIBAgITMwAAfQ8MRyV/yVPnYwAAAAB9DzANBgkqhkiG9w0BAQUFADB5MQsw
CQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJ
bnRlbCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBD
QSA0QTAeFw0xNjAzMjMxMjU3MDJaFw0xNzAzMTgxMjU3MDJaMEExFzAVBgNVBAMTDlZhcmxlc2Us
IE1hcmNvMSYwJAYJKoZIhvcNAQkBFhdtYXJjby52YXJsZXNlQGludGVsLmNvbTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBANWFfD5N9XAuYWdFkj4C5MoRvGFqUU7/qrrNEt3UsoNTqzKf
2KNoR0C2FsRnsivsjQC0EWx32kUToJcUqm182NBsoIMo5Oe/8JpruDHPZ+BLpLEnafqaZ4ZF1fFf
NlRa/ljKmdoI8TBCaM9Q/vcgn2HxcS3DBF3Gzp+OBeM7Ln5Ma5QFIRDvVTIeFBiS092GGUTMVscr
FI9u70ZaZ6zfgcPq6nJwGhDpi3t6QGFflSuNTC614H+47uELLIMMPydMhZmLAxudtJm8Ohf4Hhdf
epc6Y2c1I/LZDv+HkPWFZ3WC30Z6K/uoUKjaJiwkaItA06MYmKVI+FKGzObxdDKSSgcCAwEAAaOC
AjEwggItMAsGA1UdDwQEAwIHgDA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiGw4x1hJnlUYP9
gSiFjp9TgpHACWeB3r05lfBDAgFkAgEJMB0GA1UdDgQWBBT5LsQt79l5zcmGHP1WAspDLugYjDAf
BgNVHSMEGDAWgBQeaSq03Cj+RxhOIQs/vKwRL/CY9TBlBgNVHR8EXjBcMFqgWKBWhlRodHRwOi8v
d3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L0NSTC9JbnRlbCUyMEV4dGVybmFsJTIwQmFzaWMlMjBJ
c3N1aW5nJTIwQ0ElMjA0QS5jcmwwgZ8GCCsGAQUFBwEBBIGSMIGPMGkGCCsGAQUFBzAChl1odHRw
Oi8vd3d3LmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFs
JTIwQmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjA0QS5jcnQwIgYIKwYBBQUHMAGGFmh0dHA6Ly9vY3Nw
LmludGVsLmNvbS8wHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQBgjcKAwwwKQYJKwYBBAGCNxUK
BBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMEsGA1UdEQREMEKgJwYKKwYBBAGCNxQCA6AZ
DBdtYXJjby52YXJsZXNlQGludGVsLmNvbYEXbWFyY28udmFybGVzZUBpbnRlbC5jb20wDQYJKoZI
hvcNAQEFBQADggEBAM5qHolwebSV+VWrDtiWU+VbdWKdp1AvV0aceB0/btbPwPFEJQo1/r571RxU
hW31+1i82M9JhA56oSxbk8WTRe5OHx+H6vkpB2+th80InLJdfSzvvq2LAT09r6XcFuXOFqRqZnBG
r4r+OAsVGIXFQP9zFtpSjp05KEF5olGL871iMXJW4li4q1B+bGZg+hfHNimh80n3dLUMMQ49Dskq
oZV7geNatzBrc6ZhTnDEITKsXt8m3gmQnm7wZinDMdqa16UGtse2P/PO/v6MDMsbyw4l2FUzeFmS
bCTJFTTBCfeaiWxN3AXVE7H5a9C/P9UqTXR6YTAFvg1XfU8yvDl6owkxggJZMIICVQIBATCBkDB5
MQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQK
ExFJbnRlbCBDb3Jwb3JhdGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWlu
ZyBDQSA0QQITMwAAfQ8MRyV/yVPnYwAAAAB9DzAJBgUrDgMCGgUAoIGeMBgGCSqGSIb3DQEJAzEL
BgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2MDMzMTA4MDQyOVowIwYJKoZIhvcNAQkEMRYE
FPlRwITKSEUijh5SasJhsv4VzdVLMD8GCSqGSIb3DQEJDzEyMDAwBwYFKw4DAhowCwYJYIZIAWUD
BAIDMAsGCWCGSAFlAwQCAjALBglghkgBZQMEAgEwDQYJKoZIhvcNAQEBBQAEggEAwfQBsbloR7p6
S0SWMfPPiVhw1NDDgSH7ojY4sJ8GVqHVGfm9kqmsuVYZUSQSTnJrZcEyzXVNcqvmeGnNMYYhKBuY
p98uBwff8QJV71NmLR0eUgQnqslbnq/TAIshYvg9RQ1TUv+7YchMKV1YLkk2Cyk0ScHCXCHUCR6u
fifSv2qDPZIxInpqdaMTbWveVGqhIJBP3yqrh9kiXSdiTsJzKvoKxI6CAiAQRqH0HPNCq1EK1Kft
xI1yf38WrwvktoqoDgwZzOtyRsalfrH+E3N+xOViPyeoib5JkU5wZS367zK0y6wrGhs4t8TTp3Lh
9SIb2MF6pLB3WATirQpm3P1TTwAAAAAAAA==

------=_NextPart_000_001E_01D18B2C.5559B7A0--
