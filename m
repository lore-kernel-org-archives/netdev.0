From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] [NEIGH]: Provide number of probes to userspace
Date: 03 Mar 2005 22:52:15 -0500
Message-ID: <1109908335.1092.493.camel@jzny.localdomain>
References: <20050304023121.GC31837@postel.suug.ch>
	 <20050304.123228.08284664.yoshfuji@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: tgraf@suug.ch, "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20050304.123228.08284664.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-03 at 22:32, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <20050304023121.GC31837@postel.suug.ch> (at Fri, 4 Mar 2005 =
03:31:21 +0100), Thomas Graf <tgraf@suug.ch> says:
>=20
> > Provides number of probes done so far to userspace, quite useful for =
debugging.
> >=20
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
>=20
> It might be useful to provide probe count per state; e.g.
>   in INCOMPLETE: probes
>   in PROBLE    : probes - (ucast_probes + app_probes)
> However, we can do this in userspace.

I think this will be overkill (its like maintaining history of all the
states).

cheers,
jamal
