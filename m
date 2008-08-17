From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Sat, 16 Aug 2008 21:36:15 -0300
Message-ID: <20080816213615.689ddf8f@tux>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808162210390.7443@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Aug 2008 22:18:50 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> I'll look through 2.6.24..25 history once I have some time to see if=20
> there are some clues about the cause. I'm also having a problem in=20
> figurin out why would the frto patch you tested solve this issue (unl=
ess=20
> there are two issues in the picture).

	Ok, surely some patch between .24 and .25 caused this. Or it's
some bug that only "appeared" in .25 :)

	In fact, the frto patch helped, but not prevented the problem.
I mean, it seems that with the frto patch, the problem doesn't happen
frequently. And if I disable frto, the problem doesn't occur either.

	But, maybe, we could be talking about another bug, completely
unrelated to frto... I don't know. i'm just guessing ;). Anyway, we
talk about stalled connections ;)

	What I know is:

1) what you wrote is right: 2.6.24 is fine, 2.6.25 and 2.6.26 not

2) nmap -sS <server> seems to reset the connection (it's my workaround
until now ;). Maybe the ping probe help in some way? I don't know.

	I want to help you as much as I can. So, ask anything you need.

	Thanks!


--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
