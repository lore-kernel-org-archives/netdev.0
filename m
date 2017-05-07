From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Sun, 7 May 2017 14:02:05 -0700
Message-ID: <20170507140205.57e2ddf9@xeon-e3>
References: <20170504180216.7665-1-leon@kernel.org>
        <20170505085457.0029edc9@griffin>
        <20170505131754.GH22833@mtr-leonro.local>
        <20170506104826.GD2017@nanopsycho>
        <20170507063329.GL22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/jqskOgVPcpuGIai6uwFhhwF"; protocol="application/pgp-signature"
Cc: Jiri Pirko <jiri@resnulli.us>, Jiri Benc <jbenc@redhat.com>,
        Doug Ledford <dledford@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Ram Amrani <ram.amrani@cavium.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Christoph Hellwig <hch@lst.de>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:33988 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754580AbdEGV4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 17:56:06 -0400
Received: by mail-pg0-f43.google.com with SMTP id u28so13020499pgn.1
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 14:56:06 -0700 (PDT)
In-Reply-To: <20170507063329.GL22833@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/jqskOgVPcpuGIai6uwFhhwF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 7 May 2017 09:33:29 +0300
Leon Romanovsky <leon@kernel.org> wrote:

> On Sat, May 06, 2017 at 12:48:26PM +0200, Jiri Pirko wrote:
> > Fri, May 05, 2017 at 03:17:54PM CEST, leon@kernel.org wrote: =20
> > >On Fri, May 05, 2017 at 08:54:57AM +0200, Jiri Benc wrote: =20
> > >> On Thu,  4 May 2017 21:02:08 +0300, Leon Romanovsky wrote: =20
> > >> > In order to close object model, ensure reuse of existing code and =
make this
> > >> > tool usable from day one, we decided to implement wrappers over le=
gacy sysfs
> > >> > prior to implementing netlink functionality. As a nice bonus, it w=
ill allow
> > >> > to use this tool with old kernels too. =20
> > >>
> > >> This sounds wrong. We don't support legacy ioctl interface for the '=
ip'
> > >> command, either. I think rdma should be converted to netlink first a=
nd
> > >> the new tool should only use netlink. =20
> > >
> > >RDMA in slightly different situation than "ip" tool was. "ip" was impl=
emented
> > >when tools like ifconfig existed. It allowed to old and new systems to=
 be
> > >configured to some degree. In RDMA community, there are no similar too=
ls like
> > >"ifconfig". Implementation in netlink-only interface will leave old sy=
stems without
> > >common tool at all.
> > >
> > >As an upstream-oriented person, I personally fine with that, but anywa=
y would
> > >like to get wider agreement/disagreement on that, before removing sysfs
> > >parsing logic from the rdmatool. =20
> >
> > I tend to agree with Jiri Benc. I fear that supporting sysfs + netlink
> > api later on for the same things will make the code unnecessary complex.
> > Also, the legacy sysfs will most likely stay there forever so there will
> > be no actual motivation to port the existing things to the new netlink
> > api.
> >
> > For the prototyping purposes, I belive that what you did makes perfect
> > sense. But for the actual mergable version, my feeling is that we need
> > to strictly stick with new netlink rdma interface and just forget about
> > the old sysfs one. Distros would have to backport the new kernel
> > rdma netlink api. =20
>=20
> Thanks,
> It looks like that most of the comments are in favor of netlink-only
> solution.

If current (like 4.10 or later) kernel support netlink only solution, that =
makes sense.
When I created bridge command; it also abandoned the old ioctl interface.

--Sig_/jqskOgVPcpuGIai6uwFhhwF
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEn2/DRbBb5+dmuDyPgKd/YJXN5H4FAlkPi00ACgkQgKd/YJXN
5H4n2RAAk3JOwyunSlUHuppdrK2IG21Bh8Jb2e8AVAI6If+2wnwtLlisyxz67UOq
tNNsQTf+fpjPLMGLuY78Lfk0Y0dlF4E4MIY2KyRRaKQUo9wvnMKLjwEKL7vJJ6U6
oTXjY/ox6PRIyIbtT9bZjoi4tsAJRMWPSeKzxAPmetlVnUUW9luomFRsN22rakTR
BCdiIS1z3j6mvNG2k67Ta6b7UxrYnamy0MVVSZDr3w8JGgHd8RDCxvexwEBRRc+q
J+K/Sp1nvT5m7HyD88obneTIW9I+gXG5wcDqhptfNLcOQFir3pwB89xxlxQBqn+P
qYvw6hc1DabfKcwDeB1uvYjklGbdFgpgZO+K08b0ZNqsUyC5xLYWXOo0zaC5jMoI
a0O6QJMzQvhyWlWwI1O7FdqeWnIKsATSzh6H3M9/KKrgjYOXNDvDIL4BhMzw8Md7
3xYwA9jRiRXQ7+AVl9+HRRsHluuGk/kWnwbE+7ezuurz37P+J1MuuSenOUEa9gqk
asZpO0whhDM7K8ea5fWMz6EaQB73Udo9d6OjxwHd2PnLaR9S7szWQIMRHtw43vqJ
DnsaPtEsMJVWOqnnulXrxP2dXx1cPGi+aIpgDLZx/GnNJX6brINMhd5LGwDqKRbv
1MdWighqTwaTl7v+BGeTB8fY0DcS8DKcUpkrf+oa7UQ1QBhmcgU=
=Awhk
-----END PGP SIGNATURE-----

--Sig_/jqskOgVPcpuGIai6uwFhhwF--
