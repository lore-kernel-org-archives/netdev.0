From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Clear IFF_XMIT_DST_RELEASE for teql interfaces
Date: Wed, 16 Jun 2010 16:14:20 +0200
Message-ID: <1276697660.2632.79.camel@edumazet-laptop>
References: <1276676668-10256-1-git-send-email-tom@compton.nu>
	 <1276694745.3862.1.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Hughes <tom@compton.nu>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276694745.3862.1.camel@bigi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 juin 2010 =C3=A0 09:25 -0400, jamal a =C3=A9crit :
> On Wed, 2010-06-16 at 09:24 +0100, Tom Hughes wrote:
> > The sch_teql module, which can be used to load balance over a set o=
f
> > underlying interfaces, stopped working after 2.6.30 and has been
> > broken in all kernels since then for any underlying interface which
> > requires the addition of link level headers.
> >=20
> > The problem is that the transmit routine relies on being able to
> > access the destination address in the skb in order to do address
> > resolution once it has decided which underlying interface it is goi=
ng
> > to transmit through.
> >=20
> > In 2.6.31 the IFF_XMIT_DST_RELEASE flag was introduced, and set by
> > default for all interfaces, which causes the destination address to=
 be
> > released before the transmit routine for the interface is called.
> >=20
> > The solution is to clear that flag for teql interfaces.
> >=20
> > Signed-off-by: Tom Hughes <tom@compton.nu>
>=20
> Sounds reasonable. Lets CC Eric and get his ACK.
>=20
> cheers,
> jamal
>=20

Sure, I already Acked in on a previous message 5 days ago (although not
a formal patch, Stephen forwarded a bugzilla entry)

http://permalink.gmane.org/gmane.linux.network/163688

Please David, could you add bugzilla entry in commit ?

https://bugzilla.kernel.org/show_bug.cgi?id=3D16183

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !
