From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 15 Aug 2008 18:59:40 -0300
Message-ID: <20080815185940.1170e415@tux>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
	<20080812.011822.155249871.davem@davemloft.net>
	<20080812144309.7d62fd86@tux>
	<Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi>
	<20080813145310.0c1e534c@tux>
	<Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
	<20080815013407.4a594288@tux>
	<Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2008 10:06:39 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> I would be better to have tcpdump running at least a bit back (2-3 wi=
ndows=20
> back is long enough for me), but obviously that might not be possible=
=20
> option because it occurs so rarely. ...It should be possible to have=20
> tcpdump restarted once in a while to avoid a one huge log if you'd ju=
st=20
> keep running tcpdump from beginning.

	Ok.

> What do you mean by "come back alive"...? ...In eth0 log I found this=
=20
> connection 189.38.18.122.995 > 192.168.0.2.35477, the ip matches with=
=20
> abusar's. But I'm not sure if the connection in the tunnel is the=20
> interesting one, since it's going to/from port 119 but the ip address=
es=20
> (10.195.195.2 and 10.195.195.1) don't tell anything to me, I guess yo=
u=20
> know their meaning (ie., if 10.195.195.2 is the one with which the=20
> connection stalls)? ...You're probably right that this wasn't very us=
eful=20
> log, the longest "stall" I find is only 1.111328 seconds long (and it=
=20
> might be due to some processing that is made by 10.195.195.2).

	By "come back alive" I mean when the connection isn't stalled
anymore.

189.38.18.122 -> server

10.195.195.1 -> my local VPN ip (tun1)

10.195.195.2 -> remote VPN ip (on the server)

192.168.0.2 -> my local ip (eth0)

	Should I run tcpdump on the server too, or is it sufficient to
dump just on my client machine?

	Thank you very much again.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
