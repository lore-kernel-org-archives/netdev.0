From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Tue, 07 Jun 2011 20:31:24 +0200
Message-ID: <1307471484.3091.43.camel@edumazet-laptop>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com>
	 <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com>
	 <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com>
	 <4DEE4538.1020404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Brad Campbell <brad@fnarfbargle.com>, Bart De Schuymer
 <bdschuym@pandora.be>,  kvm@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  netdev@vger.kernel.org,
 netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4DEE4538.1020404@trash.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 07 juin 2011 =C3=A0 17:35 +0200, Patrick McHardy a =C3=A9crit :

> The main suspects would be NAT and TCPMSS. Did you also try whether
> the crash occurs with only one of these these rules?
>=20
> > I've just compiled out CONFIG_BRIDGE_NETFILTER and can no longer acce=
ss
> > the address the way I was doing it, so that's a no-go for me.
>=20
> That's really weird since you're apparently not using any bridge
> netfilter features. It shouldn't have any effect besides changing
> at which point ip_tables is invoked. How are your network devices
> configured (specifically any bridges)?

Something in the kernel does=20

u16 *ptr =3D addr (given by kmalloc())

ptr[-1] =3D 0;

Could be an off-one error in a memmove()/memcopy() or loop...

I cant see a network issue here.

I checked arch/x86/lib/memmove_64.S and it seems fine.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
