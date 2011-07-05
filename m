From: Chris Fries <qcf001@motorola.com>
Subject: Fwd: usbnet suspend issue
Date: Tue, 5 Jul 2011 13:43:17 -0500
Message-ID: <CADuEq9DosCUpw9CnLrgQPXFojeCqEy-BHfZd1_BgvRJdFFQ9Ow@mail.gmail.com>
References: <CADuEq9DkdMixSyOAHNvJa5z4uuasekr=9xkE2jHnE-vpMvj3-Q@mail.gmail.com>
 <201107051149.59963.oliver@neukum.org> <CADuEq9BkW8iHQjacohGJUZzwh--ZrqVEKYa4DzftH9XnMc=JNw@mail.gmail.com>
Reply-To: C.Fries@Motorola.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd25e220c1c7604a756df9d
To: netdev@vger.kernel.org, stable@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og113.obsmtp.com ([64.18.0.26]:56802 "EHLO
	exprod5og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab1GESoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:44:20 -0400
Received: from il93mgrg01.am.mot-mobility.com ([10.176.129.42])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p65IfITL025768
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 14:41:18 -0400 (EDT)
Received: from mail-pv0-f170.google.com (mail-pv0-f170.google.com [74.125.83.170])
	by il93mgrg01.am.mot-mobility.com (8.14.3/8.14.3) with ESMTP id p65IWuba021323
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2011 14:41:18 -0400 (EDT)
Received: by mail-pv0-f170.google.com with SMTP id 10so7108900pvh.15
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:44:18 -0700 (PDT)
In-Reply-To: <CADuEq9BkW8iHQjacohGJUZzwh--ZrqVEKYa4DzftH9XnMc=JNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd25e220c1c7604a756df9d
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

(Plain text)

Hi David, Netdev, Stable,

Please evaluate the attached usbnet patch for inclusion to the kernel.

Thanks,
Chris



On Tue, Jul 5, 2011 at 4:49 AM, Oliver Neukum <oliver@neukum.org> wrote:
>
> Am Dienstag, 5. Juli 2011, 04:25:39 schrieb Chris Fries:
> > Hi Oliver,
> >
> > I noticed a bug in usbnet suspend, that's been around for a while and s=
eems
> > to be still present in 3.0. =A0It causes some nasty behavior on ARM (Te=
gra)
> > when suspend/resume stops working due to a lost suspend count.
> > ...
>
> Thank you. That is a very good catch. Please resend to David Miller
> and netdev@vger.kernel.org and stable@kernel.org. Also please include
> your Signed-off-by: <mail> line. That way it'll be included fastest.
>
> =A0 =A0 =A0 =A0Regards
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Oliver

--000e0cd25e220c1c7604a756df9d
Content-Type: application/octet-stream; name="usbnet-suspend.patch"
Content-Disposition: attachment; filename="usbnet-suspend.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gpr6603e0

RnJvbSA5NjMzNjBiOTU1YmFlNTg5NjMzOTkxMjRiNGE1NDI4MjdmMzI3MmVhIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBDaHJpcyBGcmllcyA8Qy5Gcmllc0Btb3Rvcm9sYS5jb20+CkRh
dGU6IEZyaSwgMSBKdWwgMjAxMSAxNToyODo1OCAtMDUwMApTdWJqZWN0OiBbUEFUQ0hdIHVzYjog
dXNibmV0OiBzdXNwZW5kIGNvdW50IGdldHMgbG9zdCB3aGVuIC1FQlVTWQoKV2hlbiBzdXNwZW5k
IGlzIHJlZnVzZWQgZHVlIHRvIHBlbmRpbmcgdHJhbnNtaXRzLCB0aGUKYnVzeSBjb3VudGVyIGdl
dHMgb3V0IG9mIHN5bmMsIGFuZCBzdXNwZW5kIHdpbGwgc3RvcAp3b3JraW5nIGNvcnJlY3RseS4K
CkNoYW5nZS1JZDogSTg5ZDMxZDY1ODRlODkxNDE5MjMxNTY3MWM4MDMxYTljNzY1OGNhMjIKU2ln
bmVkLW9mZi1ieTogQ2hyaXMgRnJpZXMgPEMuRnJpZXNAbW90b3JvbGEuY29tPgotLS0KIGRyaXZl
cnMvbmV0L3VzYi91c2JuZXQuYyB8ICAgIDEgKwogMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlv
bnMoKyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvdXNiL3VzYm5l
dC5jIGIvZHJpdmVycy9uZXQvdXNiL3VzYm5ldC5jCmluZGV4IGNjOTVhYWQuLjliY2MzZTMgMTAw
NjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VzYi91c2JuZXQuYworKysgYi9kcml2ZXJzL25ldC91c2Iv
dXNibmV0LmMKQEAgLTE0NTEsNiArMTQ1MSw3IEBAIGludCB1c2JuZXRfc3VzcGVuZCAoc3RydWN0
IHVzYl9pbnRlcmZhY2UgKmludGYsIHBtX21lc3NhZ2VfdCBtZXNzYWdlKQogCQkvKiBkb24ndCBh
dXRvc3VzcGVuZCB3aGlsZSB0cmFuc21pdHRpbmcgKi8KIAkJaWYgKGRldi0+dHhxLnFsZW4gJiYg
KG1lc3NhZ2UuZXZlbnQgJiBQTV9FVkVOVF9BVVRPKSkgewogCQkJc3Bpbl91bmxvY2tfaXJxKCZk
ZXYtPnR4cS5sb2NrKTsKKwkJCWRldi0+c3VzcGVuZF9jb3VudC0tOwogCQkJcmV0dXJuIC1FQlVT
WTsKIAkJfSBlbHNlIHsKIAkJCXNldF9iaXQoRVZFTlRfREVWX0FTTEVFUCwgJmRldi0+ZmxhZ3Mp
OwotLSAKMS43LjAuNAoK
--000e0cd25e220c1c7604a756df9d--
