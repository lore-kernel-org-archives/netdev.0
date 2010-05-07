From: Lars Eggert <lars.eggert@nokia.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 7 May 2010 11:46:40 +0300
Message-ID: <70125082-4A0B-4E54-A7F6-B6CDC0375E78@nokia.com>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com> 	 <o2h571fb4001005032030tdf02a4fag520ec4e56ebdb8df@mail.gmail.com> 	 <1272972722.2097.1.camel@achroite.uk.solarflarecom.com> 	 <l2s571fb4001005040728t91979906ofa10cf0714c305b2@mail.gmail.com> 	 <20100504091215.5a4a51f4@nehalam> 	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com> 	 <20100504101301.5f4dd9c2@nehalam> 	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com> 	 <1273085598.2367.233.camel@edumazet-laptop> 	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com> <1273147586.2357.63.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: multipart/signed; boundary=Apple-Mail-70-709540720; protocol="application/pkcs7-signature"; micalg=sha1
Cc: Bhaskar Dutta <bhaskie@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:41177 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab0EGIrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 04:47:04 -0400
In-Reply-To: <1273147586.2357.63.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-70-709540720
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On 2010-5-6, at 15:06, Eric Dumazet wrote:
> This code should be completely rewritten for linux-2.6.35, its very =
ugly
> and over complex, yet it is not scalable.

Let me quickly point out that the IETF has recently replaced TCP-MD5 =
with TCP-AO (http://tools.ietf.org/html/draft-ietf-tcpm-tcp-auth-opt-11) =
which is days or weeks away from being published as an RFC. (The draft =
has been approved and it waiting for the RFC Editor to finish the final =
copy-editing.)

You'll obviously still want TCP-MD5 support for talking to existing =
equipment, but significant cycles would IMO be better spent on TCP-AO.

Lars=

--Apple-Mail-70-709540720
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIGbDCCAyUw
ggKOoAMCAQICEAdjk36sXKbnVn15S0/qUp0wDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCWkEx
JTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNVBAMTI1RoYXd0ZSBQ
ZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMB4XDTA5MDYxNTExMjYxNFoXDTEwMDYxNTExMjYx
NFowXDEPMA0GA1UEBBMGRWdnZXJ0MQ0wCwYDVQQqEwRMYXJzMRQwEgYDVQQDEwtMYXJzIEVnZ2Vy
dDEkMCIGCSqGSIb3DQEJARYVbGFycy5lZ2dlcnRAbm9raWEuY29tMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA7mR8A+Pn0/FsUkMX6Pyjw+FL3IFcJk8GaKV5VJ40TMI0Wh8oq20cqA9X
uqnVDW9WztKwH+o+msJenLwWpprbpJm4TImYGbnUJxYyN8gb81aiX1Bw2xCpJ5z3H2+8DsReJLuY
Rdl4bVvaIxLIL4odmfsRwzPyNkOK8LRtfl6OPcaDOlFWzbikULfIVGGu7BqK4lxQSpYwwpZkOMOB
6nnBSfUOtBEmqO+qZG/nL/JxWFV5vxQgg4XHbsMMTxFf6+ji18BD09BUIfDLTuJoCzFmQhrM9vLT
VuRhHWSL20LoafGjXv6mPt3i9IGJHpVb2dMQUgOgRyWHTKiUJVU/rUTdWwIDAQABo14wXDAqBgUr
ZQEEAQQhMB8CAQAwGjAYAgEEBBNMMnVNeWZmQk5VYk5KSmNkWjJzMCAGA1UdEQQZMBeBFWxhcnMu
ZWdnZXJ0QG5va2lhLmNvbTAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBBQUAA4GBADUx+67n98wt
I1vydB90HeSZP4Y64VCxxb0NxGGFvfc2+JdVKeHJ/xT+l+ygYKsWNwJJprkPi4WZ5G0crkq4VK1H
5drEJIztpSPVfWI05vPidaaGuuuCR+6MvJMtOTEYEvc/6eovBnkrzRf9x5x5EyuJXAWTeuBADg80
QI3vQ1tZMIIDPzCCAqigAwIBAgIBDTANBgkqhkiG9w0BAQUFADCB0TELMAkGA1UEBhMCWkExFTAT
BgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJQ2FwZSBUb3duMRowGAYDVQQKExFUaGF3dGUg
Q29uc3VsdGluZzEoMCYGA1UECxMfQ2VydGlmaWNhdGlvbiBTZXJ2aWNlcyBEaXZpc2lvbjEkMCIG
A1UEAxMbVGhhd3RlIFBlcnNvbmFsIEZyZWVtYWlsIENBMSswKQYJKoZIhvcNAQkBFhxwZXJzb25h
bC1mcmVlbWFpbEB0aGF3dGUuY29tMB4XDTAzMDcxNzAwMDAwMFoXDTEzMDcxNjIzNTk1OVowYjEL
MAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAqBgNV
BAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBMIGfMA0GCSqGSIb3DQEBAQUA
A4GNADCBiQKBgQDEpjxVc1X7TrnKmVoeaMB1BHCd3+n/ox7svc31W/Iadr1/DDph8r9RzgHU5VAK
MNcCY1osiRVwjt3J8CuFWqo/cVbLrzwLB+fxH5E2JCoTzyvV84J3PQO+K/67GD4Hv0CAAmTXp6a7
n2XRxSpUhQ9IBH+nttE8YQRAHmQZcmC3+wIDAQABo4GUMIGRMBIGA1UdEwEB/wQIMAYBAf8CAQAw
QwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC50aGF3dGUuY29tL1RoYXd0ZVBlcnNvbmFsRnJl
ZW1haWxDQS5jcmwwCwYDVR0PBAQDAgEGMCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFQcml2YXRl
TGFiZWwyLTEzODANBgkqhkiG9w0BAQUFAAOBgQBIjNFQg+oLLswNo2asZw9/r6y+whehQ5aUnX9M
Ibj4Nh+qLZ82L8D0HFAgk3A8/a3hYWLD2ToZfoSxmRsAxRoLgnSeJVCUYsfbJ3FXJY3dqZw5jowg
T2Vfldr394fWxghOrvbqNOUQGls1TXfjViF4gtwhGTXeJLHTHUb/XV9lTzGCAxAwggMMAgEBMHYw
YjELMAkGA1UEBhMCWkExJTAjBgNVBAoTHFRoYXd0ZSBDb25zdWx0aW5nIChQdHkpIEx0ZC4xLDAq
BgNVBAMTI1RoYXd0ZSBQZXJzb25hbCBGcmVlbWFpbCBJc3N1aW5nIENBAhAHY5N+rFym51Z9eUtP
6lKdMAkGBSsOAwIaBQCgggFvMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTEwMDUwNzA4NDY0MFowIwYJKoZIhvcNAQkEMRYEFKhCwyggciBMib5vxnoRYFcfS0zVMIGF
BgkrBgEEAYI3EAQxeDB2MGIxCzAJBgNVBAYTAlpBMSUwIwYDVQQKExxUaGF3dGUgQ29uc3VsdGlu
ZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVyc29uYWwgRnJlZW1haWwgSXNzdWluZyBD
QQIQB2OTfqxcpudWfXlLT+pSnTCBhwYLKoZIhvcNAQkQAgsxeKB2MGIxCzAJBgNVBAYTAlpBMSUw
IwYDVQQKExxUaGF3dGUgQ29uc3VsdGluZyAoUHR5KSBMdGQuMSwwKgYDVQQDEyNUaGF3dGUgUGVy
c29uYWwgRnJlZW1haWwgSXNzdWluZyBDQQIQB2OTfqxcpudWfXlLT+pSnTANBgkqhkiG9w0BAQEF
AASCAQC8193J64epW57wRI46yiKiFG/VwtWSRF1Ss3OeNidgDX2ZD98muxxneKt6/WSlXdOKspuz
ncaYw2zRuPQRqdV0pgVuXplSxavlnMgrR3r9vYkDZ7kqqcIg3Kggs6ACLoq/ZtDiJl2Hd8RE0xu1
2ya87fAfC5GSw8FVoBy5VC7GqNEP0rzgutPecFax4PdVD/sXGT9yuMe/QSTxLGx/eXys1dlBi6ub
OVJIDJw61UXdhdturUjWegp2etXQAgGB+o4aFkaVdEiiQ4HfmEXTrRmAQs4CEx2ONBn0mrfW/UiH
UP9i0bBtr55PxKc591R0zoPa+AQxfZi53EWrx08VVlMFAAAAAAAA

--Apple-Mail-70-709540720--
