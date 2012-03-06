From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] conntrack, suspicious RCU usage
Date: Mon, 05 Mar 2012 22:01:09 -0800
Message-ID: <1331013669.2474.31.camel@edumazet-laptop>
References: <1330950269-32668-1-git-send-email-hans.schillstrom@ericsson.com>
	 <20120305170548.GA28986@1984> <20120305223815.GA30456@1984>
	 <201203060658.16156.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201203060658.16156.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 06 mars 2012 =C3=A0 06:58 +0100, Hans Schillstrom a =C3=A9crit=
 :
> On Monday 05 March 2012 23:38:15 Pablo Neira Ayuso wrote:
> > On Mon, Mar 05, 2012 at 06:05:48PM +0100, Pablo Neira Ayuso wrote:
> > > On Mon, Mar 05, 2012 at 01:24:29PM +0100, Hans Schillstrom wrote:
> > > > From: Hans Schillstrom <hans@schillstrom.com>
> > > >=20
> > > > Hello Pablo
> > > > I think you lost this patch from Eric, I updated the patch for =
the=20
> > > > latest nf_conntrack_netlink.c=20
> > > >=20
> > > > Well, __nf_ct_l4proto_find() being out of line and the way we a=
lready
> > > > use rcu_read_lock() in this code, it seems following patch is
> > > > the most natural way to cope with these lockdep warnings.
> > >=20
> > > I'll take the previous patch to pass it to current -rc. Thanks Ha=
ns.
> >=20
> > I'll pass it to net-next, otherwise this will result in one conflic=
t
> > with one patch already in net-next if I pass it to net.
> >
> =20
> Thanks a lot
> /Hans

Thanks guys, I completely forgot to make sure this patch was applied.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
