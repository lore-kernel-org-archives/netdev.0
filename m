From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible netfilter-related memory corruption in 2.6.37
Date: Mon, 14 Feb 2011 16:11:23 +0100
Message-ID: <1297696283.2996.33.camel@edumazet-laptop>
References: <4D594313.4050009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org,
	Marcelo Tosatti <mtosatti@redhat.com>,
	nicolas prochazka <prochazka.nicolas@gmail.com>,
	KVM list <kvm@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D594313.4050009@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 14 f=C3=A9vrier 2011 =C3=A0 16:58 +0200, Avi Kivity a =C3=A9cr=
it :
> We see severe memory corruption in kvm while used in conjunction with=
=20
> bridge/netfilter.  Enabling slab debugging points the finger at a=20
> netfilter chain invoked from the bridge code.
>=20
> Can someone take a look?
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D27052
>=20

CC netdev

Does a revert of commit ca44ac386181ba7 help a bit ?

(net: don't reallocate skb->head unless the current one hasn't the
needed extra size or is shared)




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
