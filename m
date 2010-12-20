From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 16:56:22 +0800
Message-ID: <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
References: <4D0DEDF9.7020102@itcare.pl> <1292773433.18869.153.camel@edumazet-laptop>
 <4D0E2E52.3090802@itcare.pl> <AANLkTimMY3D_HssWb=Sw=b3tsxEKACk2QUzFzi-HaC-J@mail.gmail.com>
 <4D0E6C6D.10806@itcare.pl> <4D0E8416.2030100@gmail.com> <4D0E857E.5060302@gmail.com>
 <4D0E868F.90005@gmail.com> <4D0F0D73.2080807@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30433fa0ed59a70497d3b2ef
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:37734 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520Ab0LTI4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 03:56:43 -0500
Received: by fxm18 with SMTP id 18so2759039fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 00:56:42 -0800 (PST)
In-Reply-To: <4D0F0D73.2080807@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf30433fa0ed59a70497d3b2ef
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

2010/12/20 Pawe=C5=82 Staszewski <pstaszewski@itcare.pl>:
>>
> Yes reverting this patch solves the problem.
>
>

I am not sure reverting is the right fix. Maybe you can try this patch
attached instead.

BTW: there are some others NIC drivers and net_sched actions don't
take care of shared skbs.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

--20cf30433fa0ed59a70497d3b2ef
Content-Type: text/plain; charset=US-ASCII; name="x.diff"
Content-Disposition: attachment; filename="x.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ghx4nn840

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2l4Z2JlL2l4Z2JlX21haW4uYyBiL2RyaXZlcnMvbmV0
L2l4Z2JlL2l4Z2JlX21haW4uYwppbmRleCBjYTkwMzZkLi42MDJjZDMyIDEwMDY0NAotLS0gYS9k
cml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmMKKysrIGIvZHJpdmVycy9uZXQvaXhnYmUvaXhn
YmVfbWFpbi5jCkBAIC02MDk2LDYgKzYwOTYsMTUgQEAgc3RhdGljIGludCBpeGdiZV90c28oc3Ry
dWN0IGl4Z2JlX2FkYXB0ZXIgKmFkYXB0ZXIsCiAJdTMyIG1zc19sNGxlbl9pZHgsIGw0bGVuOwog
CiAJaWYgKHNrYl9pc19nc28oc2tiKSkgeworCQlpZiAoc2tiX3NoYXJlZChza2IpKSB7CisJCQlz
dHJ1Y3Qgc2tfYnVmZiAqbnNrYjsKKworCQkJbnNrYiA9IHNrYl9jbG9uZShza2IsIEdGUF9BVE9N
SUMpOworCQkJaWYgKCFuc2tiKQorCQkJCXJldHVybiAtRU5PTUVNOworCQkJa2ZyZWVfc2tiKHNr
Yik7CisJCQlza2IgPSBuc2tiOworCQl9CiAJCWlmIChza2JfaGVhZGVyX2Nsb25lZChza2IpKSB7
CiAJCQllcnIgPSBwc2tiX2V4cGFuZF9oZWFkKHNrYiwgMCwgMCwgR0ZQX0FUT01JQyk7CiAJCQlp
ZiAoZXJyKQo=
--20cf30433fa0ed59a70497d3b2ef--
