From: Andreas Petlund <andreas@petlund.no>
Subject: forcedeth MCP55 msi problems
Date: Thu, 6 Nov 2008 17:31:46 +0100
Message-ID: <037FCE6B-850E-4A88-B4C3-B856B306377E@petlund.no>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: multipart/signed; boundary=Apple-Mail-11-721287231; micalg=sha1; protocol="application/pkcs7-signature"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.2750.no ([62.101.244.198]:47733 "EHLO mail.2750.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbYKFQmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 11:42:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.2750.no (Postfix) with ESMTP id 282C5EF20A
	for <netdev@vger.kernel.org>; Thu,  6 Nov 2008 17:32:22 +0100 (CET)
Received: from mail.2750.no ([127.0.0.1])
	by localhost (mail.2750.no [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mwvxpkFwAnzX for <netdev@vger.kernel.org>;
	Thu,  6 Nov 2008 17:31:59 +0100 (CET)
Received: from [192.168.100.252] (banaitja.simula.no [129.240.228.18])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.2750.no (Postfix) with ESMTPSA id 00FBBEF208
	for <netdev@vger.kernel.org>; Thu,  6 Nov 2008 17:31:58 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-11-721287231
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

I have a machine with an Asus motherboard (P5N32-SLI Premium - NVidia  
MCP55 chipset) where the forcedeth module does not work with msi. This  
seems to bother quite some people ( see https://bugs.launchpad.net/ubuntu/+source/linux/+bug/136836 
  ).

Reading various forum posts makes me inclined to believe this is a  
firmware problem, but Asus have no fix with their latest BIOS-upgrade  
(and I am starting to believe that we will never see one as the last  
update came in March this year).

Is it an option to workaround this problem using a hardware-specific  
quirk that disables msi/msix for the device, or will that affect a lot  
of users that have no issues with this? On my system the NIC  
identifies as "cb84". I don't know if this is a common factor for all  
who has this problem, or only for my motherboard.
Maybe the benefit of making it work with all MCP55-NICs is worth  
disabling msi/msix also for unaffected ones?

Does anybody have alternative suggestions?


--Apple-Mail-11-721287231
Content-Disposition: attachment;
	filename=smime.p7s
Content-Type: application/pkcs7-signature;
	name=smime.p7s
Content-Transfer-Encoding: base64

MIAGCSqGSIb3DQEHAqCAMIACAQExCzAJBgUrDgMCGgUAMIAGCSqGSIb3DQEHAQAAoIIFrTCCBakw
ggORoAMCAQICAk2xMA0GCSqGSIb3DQEBBQUAMFQxFDASBgNVBAoTC0NBY2VydCBJbmMuMR4wHAYD
VQQLExVodHRwOi8vd3d3LkNBY2VydC5vcmcxHDAaBgNVBAMTE0NBY2VydCBDbGFzcyAzIFJvb3Qw
HhcNMDgwNTA2MTAzNjEzWhcNMTAwNTA2MTAzNjEzWjCBmTEYMBYGA1UEAxMPQW5kcmVhcyBQZXRs
dW5kMSEwHwYJKoZIhvcNAQkBFhJhbmRyZWFzQHBldGx1bmQubm8xITAfBgkqhkiG9w0BCQEWEmFw
ZXRsdW5kQHNpbXVsYS5ubzE3MDUGCSqGSIb3DQEJARYoZDdiZmQ3ZGY3MWQyNzkwZWZiOWM3YjI4
MDRkNDhmZTc2ZTIwMTNjYzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANO0FgEtdB8Q
Xiq5/0yfCk2j9t0109LVH7NvqpfwDK6+nFrpAWKdcGnwNvpDLM+fVIyK7+N0mMsj3yCUfGnQKz71
Kl0qvQ1lHKPDBvT77vlSYsVtKzibBMsZy1yBdyWkHAY2WDP1sI0p2Tc65e5qWb4Q1JQy88JuoPpF
FKZwvFsZUXsJ/YiSbY15imGfUvoMPdl9QVg2OXzL4xUZ/XmPczH+Hzc25RFmtSvRUvagT4jRjl9a
tkM1XSLa9aIEqVv5r54Yp9fx97FB9WdEcim9RpqRzFZjq5/1LuMwDuPIPepWdx8TXB11SsRCV4oE
G9c6DT68WXZOzo3AQF3K20mIBn0CAwEAAaOCAT0wggE5MAwGA1UdEwEB/wQCMAAwVgYJYIZIAYb4
QgENBEkWR1RvIGdldCB5b3VyIG93biBjZXJ0aWZpY2F0ZSBmb3IgRlJFRSBoZWFkIG92ZXIgdG8g
aHR0cDovL3d3dy5DQWNlcnQub3JnMEAGA1UdJQQ5MDcGCCsGAQUFBwMEBggrBgEFBQcDAgYKKwYB
BAGCNwoDBAYKKwYBBAGCNwoDAwYJYIZIAYb4QgQBMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcw
AYYWaHR0cDovL29jc3AuY2FjZXJ0Lm9yZzBbBgNVHREEVDBSgRJhbmRyZWFzQHBldGx1bmQubm+B
EmFwZXRsdW5kQHNpbXVsYS5ub4EoZDdiZmQ3ZGY3MWQyNzkwZWZiOWM3YjI4MDRkNDhmZTc2ZTIw
MTNjYzANBgkqhkiG9w0BAQUFAAOCAgEACQurlIpzpYGuZVl1+Oy8NXMGx2NcKxqydxATviCzKijM
4p5QzZJqUOBkSK3dd9CrTsYJMk9koujia2kxX2edMu2BwJBJVZe17bT3spJyG6eBOPGvxaCxpnlA
jeTOsVf5JAO7p+tfWAR0qj3p8P0J1C+/7okExvZMOJgm/RiLNtaGy0WrW4mhaWfmGEgvGyqGfjFf
j3f2LFQede0zm2HBEPePTxKzeZ64hWFVKQ8Nvs1csxyto764n7wZWP05VoxU/ZrBMbNiJyr8s3f7
Ee9wf/SjvoG3tJHvz/obJpkOeEvZv4jGy6drnuUk/KU2GATaxT9pqGEsPPo3xhyDT4Aa3CFb0y8q
DXXggve3ARInKACiyo2UWpRPefHctMeEg8DIV6p/8qfobr1AfBZZwtsjwRIytJarmcL1nzsqMRFH
piGstHBDjVxIy7XEz7Thjx2anBUSWKIUi0ZR/sEwlxUlaww30dUBPRVlaUKLWmOaaZZEL6a/M1mZ
xOLvRO0gFvAE4EKYrO18nOtUrKRW3bF8sUewsGND1BBOt3zvp2QSqfRy0zFpEDHCDcagpEGOLQew
mY1JnBOqt8uqlvqGE6oSz5Bf6x5ApgvxoWIJvpVszxzbayWVpzZk4rCGkuTxCDEd90U3ZXOQ5MFr
cwbVHaGt9UOUWZVz8BMKI2r/6Tvn6zkxggK6MIICtgIBATBaMFQxFDASBgNVBAoTC0NBY2VydCBJ
bmMuMR4wHAYDVQQLExVodHRwOi8vd3d3LkNBY2VydC5vcmcxHDAaBgNVBAMTE0NBY2VydCBDbGFz
cyAzIFJvb3QCAk2xMAkGBSsOAwIaBQCgggE1MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
KoZIhvcNAQkFMQ8XDTA4MTEwNjE2MzE0N1owIwYJKoZIhvcNAQkEMRYEFG05nL11K/3tf5U9RNQt
81blpcN8MGkGCSsGAQQBgjcQBDFcMFowVDEUMBIGA1UEChMLQ0FjZXJ0IEluYy4xHjAcBgNVBAsT
FWh0dHA6Ly93d3cuQ0FjZXJ0Lm9yZzEcMBoGA1UEAxMTQ0FjZXJ0IENsYXNzIDMgUm9vdAICTbEw
awYLKoZIhvcNAQkQAgsxXKBaMFQxFDASBgNVBAoTC0NBY2VydCBJbmMuMR4wHAYDVQQLExVodHRw
Oi8vd3d3LkNBY2VydC5vcmcxHDAaBgNVBAMTE0NBY2VydCBDbGFzcyAzIFJvb3QCAk2xMA0GCSqG
SIb3DQEBAQUABIIBAIb0EbE1lW16/B2w3GRv5qNBGMmflxttZUEdyeX2oI1CSw0Whma5iKqsIdko
0ZNlG/h4LtCYZkioGf2wSBtqrWyMw4AWzT/wKZf0u0bbCuEfzECEiydfg2TWV8bd2QoyA14y/61D
sBDcIr3cwgHvsp52nXEPsjZR5of2/57SMXDyPgbooYPPGOkoc/6GEcVVVU1AvC8ZsXFvp4wVVEh6
FtjTPaR79Q68jptg/fJjmi+Y3LkCZ4Fn0pNhmVJO1fM2DQeA2fOxm/vuuNvfD+42KzWso2X+zpr8
en8H/dJRxojg5d1BOAsqSjVywlob2h+kxdXnpeFpK1PhgaAVJWm30ZEAAAAAAAA=

--Apple-Mail-11-721287231--
