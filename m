From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: document IPv6 TOS mangling bug in old Linux
 kernels
Date: Fri, 17 Jun 2011 05:47:13 +0200
Message-ID: <4DFACE41.5010906@trash.net>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>	 <1307320871-31770-2-git-send-email-pablo@netfilter.org>	 <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>	 <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>	 <1308213411.4062.22.camel@nausicaa>	 <alpine.LNX.2.01.1106161705300.10015@frira.zrqbmnf.qr>	 <4DFA1DFC.3000804@trash.net>  <1308273097.8612.1.camel@nexus.oss.ntt.co.jp> <1308273246.8612.3.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Maciej <zenczykowski@gmail.com>,
	Pablo Neira Aysuo <pablo@netfilter.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: =?UTF-8?B?RmVybmFuZG8gTHVpcyBW77+9enF1ZXogQ2Fv?=
	<fernando@oss.ntt.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308273246.8612.3.camel@nexus.oss.ntt.co.jp>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.06.2011 03:14, Fernando Luis V=EF=BF=BDzquez Cao wrote:
> In Linux kernels up to and including 2.6.38, with the exception of lo=
ngterm
> releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bu=
g (*) whereby
> IPv6 TOS mangling does not behave as documented and differs from the =
IPv4
> version. The TOS mask indicates the bits one wants to zero out, so it=
 needs to
> be inverted before applying it to the original TOS field. However, th=
e
> aformentioned kernels forgo the inversion which breaks --set-tos and =
its
> mnemonics.
>=20
> (*) Fixed by upstream commit:
>     1ed2f73d90fb49bcf5704aee7e9084adb882bfc5 (netfilter: IPv6: fix DS=
CP mangle code)
>=20

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
