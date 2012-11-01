From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] net-ipv6: format %8s change to %16s in rt6_info_route
 function of route.c
Date: Thu, 01 Nov 2012 18:23:47 +0800
Message-ID: <50924DB3.9010601@asianux.com>
References: <50921A92.8000809@asianux.com> <1351760482.32673.913.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351760482.32673.913.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8801=E6=97=A5 17:01, Eric Dumazet =E5=86=
=99=E9=81=93:
> Hi Chen
>=20
> Thats a good suggestion indeed.
>=20

  thank you very much for your confirmation.

> Networking patches should be sent to netdev@vger.kernel.org (added in
> CC)

  I will do it.

>=20
> This list only cares about recent generic kernels, not RedHat ones.
>=20

  it seems "it is not suitable to send any issues which only relative
with Red Hat to linux-*@vger.kernel.org".



> If you want to provide a patch, please base it on David Miller net-ne=
xt
> [1] tree, and make it official (read Documentation/SubmittingPatches =
for
> general advices)
>=20

  ok, I will follow, thank you for your information.


> By the way, the %8s should be replaced by %s, there is no need to mak=
e
> /proc/net/ipv6_route 'beautiful'. In the past, it was *needed* becaus=
e
> each line had to be of a given length, but its not anymore the case.
>=20
> Thanks
>=20

1) I agree with your result.

2) But for the "reason", I have my opinions:
   A) %.8s :  for limitation of output string length.
   B) %8s  :  for width of output string length (but not limit 8).
   C) %8.8s:  both limitation and width.

3) for rt->rt6i_dev->name:
   A) original %8s is not a bug for name len is more than 8 (can still
be outputted correctly)
   B) it is only effect with name len is less than 8 (it will fill some
' ' before the name)
   C) this is the reason why I call it "beautiful", not a bug.


> [1] :
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next.git;a=3Dsu=
mmary
>=20

  I will reference it, thanks.


--=20
Chen Gang

Asianux Corporation
