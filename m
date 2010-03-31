From: Neil Horman <nhorman@redhat.com>
Subject: Re: [r8169] WARNING: at net/sched/sch_generic.c
Date: Wed, 31 Mar 2010 09:35:33 -0400
Message-ID: <20100331133533.GD13963@hmsreliant.think-freely.org>
References: <20100331102142.GA3294@swordfish.minsk.epam.com>
 <20100331111942.GB13963@hmsreliant.think-freely.org>
 <20100331121426.GB3294@swordfish.minsk.epam.com>
 <1270038569.2103.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1270038569.2103.24.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2010 at 02:29:29PM +0200, Eric Dumazet wrote:
> Le mercredi 31 mars 2010 =E0 15:14 +0300, Sergey Senozhatsky a =E9cri=
t :
>=20
>=20
> > PKT_SIZE=3D"pkt_size 2048"
> >=20
>=20
> If you use 1024 bytes pktgen messages, do you still have the problem =
?
>=20
+1 I wouldn't be suprised if using something over the nominal 1522 byte=
 frame
length on r8169 caused tx errors.  The driver doesn't seem to support J=
umbo
frames, so my guess is you have to keep the packet size below 1522 byte=
s.
Neil

>=20
