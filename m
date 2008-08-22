From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 22 Aug 2008 18:32:24 -0300
Message-ID: <20080822183224.2d52f16c@tux>
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
	<20080815183511.1c81be23@tux>
	<Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
	<20080815231538.7999c017@tux>
	<Pine.LNX.4.64.0808161002500.7264@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0808162210390.7443@wrl-59.cs.helsinki.fi>
	<20080816213615.689ddf8f@tux>
	<Pine.LNX.4.64.0808181042290.23854@wrl-59.cs.helsinki.fi>
	<20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2008 15:37:13 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Based on irc discussion with davem, there is a htb bug which can caus=
e=20
> corruption of the retransmitted TCP packets (and then a discard due t=
o=20
> checksum mismatch). That would also explain the strange headers I not=
iced=20
> earlier. There's a patch below (should apply to 2.6.26), please put i=
t at=20
> least on the host(s) which use htb (I don't know if both server and t=
he=20
> client do use wondershaper script or just the client). An different=20
> failure symptoms (one could be somehow frto related as FRTO is used w=
hile=20
> retransmitting) are also quite well explainable.
>=20
> But FRTO is mostly not a suspect based on the tcpdump you provided (n=
o=20
> FRTO workaround would help in that).

	Ilpo, I have good news. I decided to disable completely HTB and
the problem seems to have gone. And frto is enabled, of course. So the
problem was with HTB, not frto as I thought.

	The HTB patches you provided are going to be included in the
next 2.6.27 kernel, right?

	Thank you.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
