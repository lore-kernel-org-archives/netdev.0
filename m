From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 16:05:47 +0200
Message-ID: <4703A1BB.1040006@free.fr>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi> <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:42786 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755153AbXJCOFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 10:05:49 -0400
In-Reply-To: <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>> On Wed, 3 Oct 2007, Cedric Le Goater wrote:
>>>
>>>> I'm dropping the previous patches you sent me and switching to thi=
s patchset.=20
>>>> right ?
>>> Yes you can do that... However, there are two ways forward:
>>>
>>> 1) Drop and test with this patchset long enough to verify it's gone=
=2E..
>>> 2) No dropping and get the more exact trace by reproducing, which c=
an=20
>>>    point out to tcp_retrans_try_collapse confirming the source of t=
he
>>>    bug or revealing yet another bug...
>>>
>>> The first one has one drawback, it cannot prove the fix very well s=
ince=20
>>> the bug could just not occur by chance... Path 2 would clearly show=
 the=20
>>> place from where the problem originates because we will know that i=
t got=20
>>> triggered! I personally would prefer path 2 but whether you want to=
 go for=20
>>> that depends on the time you want to invest in it...
>>>
>>> ...I rediffed the tcp_verify_fackets patch too (below) just in case=
 it=20
>>> would be something else in you case and you choose path 1 (put it o=
n top=20
>>> of this patchset, applies with some offsets). In case the problem i=
s gone,=20
>>> it shouldn't trigger and if it does, we'll have another bug caught.
>> I have a spare node so I'm starting 2) with the 3 patches you sent a=
nd that
>> last one which applied fine.
>=20
> Ah, that's path 1) then... Since you seem to have enough time, I woul=
d say=20
> that the path 1 is good as well and bugs unrelated to the fix will sh=
ow up=20
> there too...

arg. yes. sorry for the confusion.

> I should have stated it explicitly that with path 2 those 3 patches s=
hould=20
> not be applied because the aim is not a fix but reproducal. Path 2 wa=
s=20
> intentionally left without the potentional fix as then nice backtrace=
=20
> informs when we can stop trying (which would hopefully occurred=20
> pretty soon) :-).  But lets discard that path 2...

I have 2 spare nodes so i'll run both. 1) is on already without any iss=
ues
i'm just compiling 2)

I usually work on -mm, so what would be interesting for me is to have w=
hat you=20
need in net-2.6.24 which is getting pulled in -mm by andrew. then, if y=
ou need=20
an extra patch for verbosity, that's fine, i'll include it in my usual =
patchset.

Cheers,

C.
  =20
>> all of them on a fresh git pull of net-2.6.24
>=20
> That's fine, they're pretty well in sync (mm and net-2.6.24, and=20
> soon 2.6.24-rcs too).
>=20
