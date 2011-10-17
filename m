From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev: use ifindex hash for dev_seq_ops
Date: Mon, 17 Oct 2011 08:12:05 -0700
Message-ID: <20111017081205.2e41d03f@nehalam.linuxnetplumber.net>
References: <1318413446-22258-1-git-send-email-mmaruseac@ixiacom.com>
	<1318586017-17207-1-git-send-email-mmaruseac@ixiacom.com>
	<1318596791.2223.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAEnQRZCWBhTy24WkWoC_wy11YuLxWQ3GWr3v1=JcGvprq4AtmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mihai Maruseac <mihai.maruseac@gmail.com>, davem@davemloft.net,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mihai Maruseac <mmaruseac@ixiacom.com>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnQRZCWBhTy24WkWoC_wy11YuLxWQ3GWr3v1=JcGvprq4AtmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Oct 2011 11:03:54 +0300
Daniel Baluta <dbaluta@ixiacom.com> wrote:

> > This assumes device ifindexes are contained in a small range
> > [N .. N + X]
> >
> > I understand this can help some benchmarks, but in real world this =
wont
> > help that much once ifindexes are 'fragmented' (If really this mult=
i
> > thousand devices stuff is for real)
> >
> > Listen, we currently have 256 slots in the hash table.
> >
> > Can we try to make 'offset' something like =A0(slot_number<<24) +
> > (position in hash chain [slot_number]), instead of (position in dev=
ices
> > global list)
>=20
>=20
> Eric, we can refine the idea of our first patch [1], where we recorde=
d
> the (bucket, offset) pair. Stephen, do you agree with this?
>=20
>=20
> thanks,
> Daniel.
>=20
> [1] http://patchwork.ozlabs.org/patch/118331/

Using buckets is fine, my idea about ifindex was just to try and
preserve the order, but it doesn't matter.
