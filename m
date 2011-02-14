From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 16:18:15 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1102141617330.12050@obet.zrqbmnf.qr>
References: <4D594313.4050009@redhat.com> <1297696283.2996.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1297696283.2996.33.camel@edumazet-laptop>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2011-02-14 16:11, Eric Dumazet wrote:

>Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:58 +0200, Avi Kivity a =C3=A9c=
rit :
>> We see severe memory corruption in kvm while used in conjunction wit=
h=20
>> bridge/netfilter.  Enabling slab debugging points the finger at a=20
>> netfilter chain invoked from the bridge code.
>>=20
>> Can someone take a look?
>>=20
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D27052

Maybe looks familiar to https://lkml.org/lkml/2011/2/3/147
