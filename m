From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 17:39:32 +0100
Message-ID: <1297874372.30541.29.camel@edumazet-laptop>
References: <4D5BADCF.5000804@ka9q.net>
	 <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
	 <4D5BF411.4020204@ka9q.net>
	 <AANLkTikNrwd31RBj1gc6kSaT=qodS=A=YntM=72PMbDf@mail.gmail.com>
	 <4D5BFB39.8070805@ka9q.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	kaber@trash.net, netdev@vger.kernel.org
To: Phil Karn <karn@ka9q.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48094 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117Ab1BPQkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 11:40:31 -0500
Received: by bwz15 with SMTP id 15so794319bwz.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 08:40:30 -0800 (PST)
In-Reply-To: <4D5BFB39.8070805@ka9q.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 08:28 -0800, Phil Karn a =C3=A9=
crit :
> On 2/16/11 8:10 AM, richard -rw- weinberger wrote:
> > On Wed, Feb 16, 2011 at 4:58 PM, Phil Karn <karn@ka9q.net> wrote:
> >> On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
> >>> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote=
:
> >>>> The range check on vlan_id in register_vlan_device is off by one=
, and it
> >>>> prevents the creation of a vlan interface for vlan ID 4095. (OSX=
 allows
> >>>> this, I checked.)
> >>>
> >>> Then OSX should fix their code. 4095 is reserved.
> >>>
> >>
> >> If it's reserved, then it's up to the user to reserve it.
> >=20
> > No.
> >=20
> > See:
> > http://standards.ieee.org/getieee802/download/802.1Q-2005.pdf
> >=20
>=20
> Well, then I guess we all know better than the user. That's the Windo=
ws
> Way...no, wait, I thought this is Linux.
>=20
> The fact is that I did encounter a misconfigured switch using vlan 40=
95,
> and because of this off-by-one error I was unable to talk to it and f=
ix it.
>=20
> I was hoping I wouldn't have to patch every new kernel I install.
>=20

You can use an OSX gateway ;)

If we allow ID 4095, then some users will complain we violate rules.

Really you cannot push this patch in official kernel only to ease your
life ;)



