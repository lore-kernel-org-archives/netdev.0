From: Steve Chen <schen@mvista.com>
Subject: Re: TAHI CN-6-4-1 failed on Linux 2.6.32 kernel
Date: Thu, 12 Aug 2010 19:00:57 -0500
Message-ID: <AANLkTikeLtFqO4FcZKceCntycLSa-ZCPGF28t6nj=Gab@mail.gmail.com>
References: <AANLkTim-zWhq9aGrvH2PdS3VjfBvmh=qL=1Sy3Z+VPgT@mail.gmail.com>
	<4C646330.6080303@hp.com>
	<AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636d352796888c2048da92dad
Cc: usagi-users-ctl@ml.linux-ipv6.org, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:56391 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193Ab0HMABA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 20:01:00 -0400
Received: by yxg6 with SMTP id 6so665723yxg.19
        for <netdev@vger.kernel.org>; Thu, 12 Aug 2010 17:00:59 -0700 (PDT)
In-Reply-To: <AANLkTik5JOupTW97ikf1imsZrkmwgfPNsvBoSZp1S8JV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636d352796888c2048da92dad
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 12, 2010 at 6:04 PM, Steve Chen <schen@mvista.com> wrote:
> On Thu, Aug 12, 2010 at 4:10 PM, Brian Haley <brian.haley@hp.com> wrote:
>> Hi Steve,
>>
>> On 07/28/2010 11:20 PM, Steve Chen wrote:
>>> Hello,
>>>
>>> The TAHI correspondent node tests CN-6-4-1 (Processing in upper layer
>>> - Echo Checksum) failed for me in the 2.6.32 kernel. =A0It appears that
>>> the Linux kernel is replying the ICMP echo request in
>>> icmpv6_echo_reply without much checking. =A0Is this an intentional
>>> non-conformance to RFC3775 section 9.3.1?
>>
>> Sorry for the late reply. =A0I've run these tests in the past against
>> SLES11 (2.6.27 ?) back in January 2009 and this one passed from looking
>> at my logs. =A0I don't have that system around anymore to check the conf=
ig,
>> etc. =A0I didn't see any obvious commit that would have broken it from a
>> quick look, do you have a test setup to do some debugging? =A0It will
>> take a little time for me to re-configure mine to run this test.
>
> Brian,
>
> I'm using mip6d from git://www.umip.org/git/umip.git commit id
> d1c240f3deb690af902ce1ff128780551ff6141c. =A0Is that the correct version
> to use? =A0Looking at the kernel code again, the checksum error should
> have been caught in icmpv6_rcv. =A0There are probably something wrong
> with my setup. =A0I'll dig around a bit more.
>
> Tests 5-3-1 to 5-3-6 also failed for me. =A0 Did they pass for you?

By the way, these tests passed for me with the following patch.
Please let me know what you think.

Thanks

Steve

--001636d352796888c2048da92dad
Content-Type: text/x-patch; charset=US-ASCII; name="h_bit_check.patch"
Content-Disposition: attachment; filename="h_bit_check.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gcsa1q2w0

UmVpbnN0YXRlIGNoZWNrcyB0byBoYW5kbGUgQlUgd2l0aCBIIGJpdCBzZXQKCkNoZWNrIGZvciB0
aGUgSCBmbGFnIHdhcyBvbWl0dGVkIGluIDIyNzZkZGVjMzZhMzc4OTgyNjg0MmFjODMxNjU1M2Zh
MDcwMmVhODkuClRoaXMgY2F1c2VkIFRBSEkgY29ycmVjcG9uZGVuZCBub2RlIHRlc3RzIDExOC0x
MjMgKDUuMy4gUmVjZWl2aW5nIEJVIHdpdGgKKEgpYml0IGlzIHNldCkgdG8gZmFpbC4KCmRpZmYg
LS1naXQgYS9zcmMvY24uYyBiL3NyYy9jbi5jCmluZGV4IDAzMThlOWUuLmEwMzZkOTYgMTAwNjQ0
Ci0tLSBhL3NyYy9jbi5jCisrKyBiL3NyYy9jbi5jCkBAIC0xNzMsNiArMTczLDEwIEBAIHN0YXRp
YyBpbnQgY25fYnVfY2hlY2soc3RydWN0IGlwNl9taF9iaW5kaW5nX3VwZGF0ZSAqYnUsIHNzaXpl
X3QgbGVuLAogCWludCByZXQ7CiAKIAlub25faW5kID0gbWhfb3B0KCZidS0+aXA2bWhidV9oZHIs
IG1oX29wdHMsIElQNl9NSE9QVF9OT05DRUlEKTsKKworCWlmIChidS0+aXA2bWhidV9mbGFncyAm
IElQNl9NSF9CVV9IT01FKQorCQlyZXR1cm4gbm9uX2luZCA/IC0xIDogMDsKKwogCWlmICghbm9u
X2luZCkKIAkJcmV0dXJuIC0xOwogCg==
--001636d352796888c2048da92dad--
