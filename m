From: Steven Wang <steven.wang@digilentinc.com>
Subject: RE: Support for Marvell 88E1510 and 88E1116R
Date: Fri, 4 Jan 2013 14:11:36 -0800
Message-ID: <BF617F5A412EFC46879ABC89757850DE02692A29839D@SERVER.digilent.local>
References: <50E404BC.3010604@monstr.eu>	<50E45B74.70301@metafoo.de>
	<BF617F5A412EFC46879ABC89757850DE02692A298149@SERVER.digilent.local>
 <CAHTX3dKu=1azOvTM7n6M9u8AL_ujkJ5e89SeZG4fV7Q--PEAgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_BF617F5A412EFC46879ABC89757850DE02692A29839DSERVERdigil_"
Cc: Lars-Peter Clausen <lars@metafoo.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linn <linnj@xilinx.com>,
	Sam Bobrowicz <SBobrowicz@digilentinc.com>,
	Rick Hoover <RHoover@digilentinc.com>
To: Michal Simek <monstr@monstr.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust-216-98-241-030.turbonet.com ([216.98.241.30]:39200 "EHLO
	remote.digilentinc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755041Ab3ADWLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 17:11:43 -0500
In-Reply-To: <CAHTX3dKu=1azOvTM7n6M9u8AL_ujkJ5e89SeZG4fV7Q--PEAgA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_BF617F5A412EFC46879ABC89757850DE02692A29839DSERVERdigil_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi, Michal,

I have generated the patch and cleaned up the codes.
The codes was originally written by Rick Hoover.

I have sent it via git send-email command to you and git@xilinx.com.
I also attached the patch here just in case the email failed to go through.

Best Regards,
Steve

-----Original Message-----
From: Michal Simek [mailto:monstr@monstr.eu]=20
Sent: Friday, January 4, 2013 1:41 AM
To: Steven Wang
Cc: Lars-Peter Clausen; netdev@vger.kernel.org; Christian Hohnstaedt; Srini=
vas Kandagatla; David Miller; LKML; John Linn; Sam Bobrowicz; Rick Hoover
Subject: Re: Support for Marvell 88E1510 and 88E1116R

Hi Steve,

2013/1/2 Steven Wang <steven.wang@digilentinc.com>:
> Hi, Michal,
>
> We do have the Ethernet support for 88E1510 (used on ZedBoard) in our=20
> repository. The commit is
> https://github.com/Digilent/linux-digilent/commit/ae635e5fff35e9fe5928
> b4aca7264a1e5313a6b8 Or, I can send the patch to you if you need.

I know. Can you please clean this patch and send it to mainline for review?
(Remove comment and that emacps connection).

I will add this patch to our tree to support this patch.

Thanks,
Michal


--
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/ Mai=
ntainer of Linux kernel - Xilinx Zynq ARM architecture Microblaze U-BOOT cu=
stodian


--_002_BF617F5A412EFC46879ABC89757850DE02692A29839DSERVERdigil_
Content-Type: application/octet-stream;
	name="0001-Digilent-Marvell-PHY-Added-a-new-entry-for-88E1510-P.patch"
Content-Description: 0001-Digilent-Marvell-PHY-Added-a-new-entry-for-88E1510-P.patch
Content-Disposition: attachment;
	filename="0001-Digilent-Marvell-PHY-Added-a-new-entry-for-88E1510-P.patch";
	size=2401; creation-date="Fri, 04 Jan 2013 22:08:24 GMT";
	modification-date="Fri, 04 Jan 2013 22:01:55 GMT"
Content-Transfer-Encoding: base64

RnJvbSA1NGVmMGIzMjYyYzA2NTdjMmVmYWViNGQwZjBjYmI0ZDNiOWVmZGQwIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBSaWNrIEhvb3ZlciA8Ukhvb3ZlckBkaWdpbGVudGluYy5jb20+
CkRhdGU6IEZyaSwgNCBKYW4gMjAxMyAxMzo1Njo1NCAtMDgwMApTdWJqZWN0OiBbUEFUQ0hdIERp
Z2lsZW50OiBNYXJ2ZWxsIFBIWTogQWRkZWQgYSBuZXcgZW50cnkgZm9yIDg4RTE1MTAgUEhZcwoK
QWRkZWQgYSBuZXcgZW50cnkgZm9yIDg4RTE1MTAuCkFkZGVkIFBIWSBpbml0aWFsaXphdGlvbiBy
b3V0aW5lIGZvciA4OEUxNTEwLgoKU2lnbmVkLW9mZi1ieTogVGluZ2h1aSBXQU5HIChTdGV2ZW4p
IDxzdGV2ZW4ud2FuZ0BkaWdpbGVudGluYy5jb20+Ci0tLQogZHJpdmVycy9uZXQvcGh5L21hcnZl
bGwuYyAgIHwgICAyNiArKysrKysrKysrKysrKysrKysrKysrKysrKwogaW5jbHVkZS9saW51eC9t
YXJ2ZWxsX3BoeS5oIHwgICAgMSArCiAyIGZpbGVzIGNoYW5nZWQsIDI3IGluc2VydGlvbnMoKyks
IDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvcGh5L21hcnZlbGwuYyBi
L2RyaXZlcnMvbmV0L3BoeS9tYXJ2ZWxsLmMKaW5kZXggZTkxMzk3ZS4uN2FjYzYzMyAxMDA2NDQK
LS0tIGEvZHJpdmVycy9uZXQvcGh5L21hcnZlbGwuYworKysgYi9kcml2ZXJzL25ldC9waHkvbWFy
dmVsbC5jCkBAIC0zNTAsNiArMzUwLDE3IEBAIHN0YXRpYyBpbnQgbTg4ZTEzMThfY29uZmlnX2Fu
ZWcoc3RydWN0IHBoeV9kZXZpY2UgKnBoeWRldikKIAlyZXR1cm4gbTg4ZTExMjFfY29uZmlnX2Fu
ZWcocGh5ZGV2KTsKIH0KIAorc3RhdGljIGludCBtODhlMTUxMF9jb25maWdfYW5lZyhzdHJ1Y3Qg
cGh5X2RldmljZSAqcGh5ZGV2KQoreworCWludCBlcnI7CisKKwllcnIgPSBtODhlMTMxOF9jb25m
aWdfYW5lZyhwaHlkZXYpOworCWlmIChlcnIgPCAwKQorCQlyZXR1cm4gZXJyOworCisJcmV0dXJu
IG1hcnZlbGxfb2ZfcmVnX2luaXQocGh5ZGV2KTsKK30KKwogc3RhdGljIGludCBtODhlMTExNnJf
Y29uZmlnX2luaXQoc3RydWN0IHBoeV9kZXZpY2UgKnBoeWRldikKIHsKIAlpbnQgdGVtcDsKQEAg
LTg4Nyw2ICs4OTgsMjAgQEAgc3RhdGljIHN0cnVjdCBwaHlfZHJpdmVyIG1hcnZlbGxfZHJpdmVy
c1tdID0gewogCQkuY29uZmlnX2ludHIgPSAmbWFydmVsbF9jb25maWdfaW50ciwKIAkJLmRyaXZl
ciA9IHsgLm93bmVyID0gVEhJU19NT0RVTEUgfSwKIAl9LAorCXsKKwkJLnBoeV9pZCA9IE1BUlZF
TExfUEhZX0lEXzg4RTE1MTAsCisJCS5waHlfaWRfbWFzayA9IE1BUlZFTExfUEhZX0lEX01BU0ss
CisJCS5uYW1lID0gIk1hcnZlbGwgODhFMTUxMCIsCisJCS5mZWF0dXJlcyA9IFBIWV9HQklUX0ZF
QVRVUkVTLAorCQkuZmxhZ3MgPSBQSFlfSEFTX0lOVEVSUlVQVCwKKwkJLmNvbmZpZ19hbmVnID0g
Jm04OGUxNTEwX2NvbmZpZ19hbmVnLAorCQkucmVhZF9zdGF0dXMgPSAmbWFydmVsbF9yZWFkX3N0
YXR1cywKKwkJLmFja19pbnRlcnJ1cHQgPSAmbWFydmVsbF9hY2tfaW50ZXJydXB0LAorCQkuY29u
ZmlnX2ludHIgPSAmbWFydmVsbF9jb25maWdfaW50ciwKKwkJLmRpZF9pbnRlcnJ1cHQgPSAmbTg4
ZTExMjFfZGlkX2ludGVycnVwdCwKKwkJLmRyaXZlciA9IHsgLm93bmVyID0gVEhJU19NT0RVTEUg
fSwKKwl9LAorCiB9OwogCiBzdGF0aWMgaW50IF9faW5pdCBtYXJ2ZWxsX2luaXQodm9pZCkKQEAg
LTkxNSw2ICs5NDAsNyBAQCBzdGF0aWMgc3RydWN0IG1kaW9fZGV2aWNlX2lkIF9fbWF5YmVfdW51
c2VkIG1hcnZlbGxfdGJsW10gPSB7CiAJeyAweDAxNDEwZTMwLCAweGZmZmZmZmYwIH0sCiAJeyAw
eDAxNDEwZTkwLCAweGZmZmZmZmYwIH0sCiAJeyAweDAxNDEwZTQwLCAweGZmZmZmZmYwIH0sCisJ
eyAweDAxNDEwZGQwLCAweGZmZmZmZmYwIH0sCiAJeyB9CiB9OwogCmRpZmYgLS1naXQgYS9pbmNs
dWRlL2xpbnV4L21hcnZlbGxfcGh5LmggYi9pbmNsdWRlL2xpbnV4L21hcnZlbGxfcGh5LmgKaW5k
ZXggZWM0MTAyNS4uOGU5YTAyOSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9tYXJ2ZWxsX3Bo
eS5oCisrKyBiL2luY2x1ZGUvbGludXgvbWFydmVsbF9waHkuaApAQCAtMTUsNiArMTUsNyBAQAog
I2RlZmluZSBNQVJWRUxMX1BIWV9JRF84OEUxMjQwCQkweDAxNDEwZTMwCiAjZGVmaW5lIE1BUlZF
TExfUEhZX0lEXzg4RTEzMThTCQkweDAxNDEwZTkwCiAjZGVmaW5lIE1BUlZFTExfUEhZX0lEXzg4
RTExMTZSCQkweDAxNDEwZTQwCisjZGVmaW5lIE1BUlZFTExfUEhZX0lEXzg4RTE1MTAJCTB4MDE0
MTBkZDAKIAogLyogc3RydWN0IHBoeV9kZXZpY2UgZGV2X2ZsYWdzIGRlZmluaXRpb25zICovCiAj
ZGVmaW5lIE1BUlZFTExfUEhZX00xMTQ1X0ZMQUdTX1JFU0lTVEFOQ0UJMHgwMDAwMDAwMQotLSAK
MS43LjEKCg==

--_002_BF617F5A412EFC46879ABC89757850DE02692A29839DSERVERdigil_--
