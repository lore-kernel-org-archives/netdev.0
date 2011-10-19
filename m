From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave
 function.
Date: Wed, 19 Oct 2011 19:49:57 +0900
Message-ID: <20111019104945.GA17995@verge.net.au>
References: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903183@ESESSCMS0356.eemea.ericsson.se>
 <CAC52Y8ZvgBVC4_TEBFMALa-xU84PseV6w6sJO64ch+BdAqD2aA@mail.gmail.com>
 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev@vger.kernel.org
To: Hans =?utf-8?Q?Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39536 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab1JSKuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 06:50:03 -0400
Content-Disposition: inline
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903185@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2011 at 12:37:51PM +0200, Hans Schillstr=C3=B6m wrote:
>=20
> >Hello,
> >
> >[...]
> >> In my code there is another fix needed as well (todays net-next)
> >> i.e.  usage od cs  "cs =3D ip_vs_set_state(cp, IP_VS_DIR_INPUT, sk=
b, pd)"
> >[...]
> >
> >Well spotted in terms of "net-next" branch and/or repository.
> >
> >In my case, I was working against "ipvs-next" using Simon's tree on
> >github (I have made the fork when kernel.org facilities were not
> >available at the time): https://github.com/horms/ipvs-next, and the
> >code line you still appear to have in Dave's "net-next" (if that is
> >the one) was amended in the following commit made against "ipvs-next=
":
>=20
> Sorry, I didn't use that repo...
> (waiting for ipvs return to kernel.org)

It may take a little while for me to get into the new
kernel.org web of trust which needs to happen before
ipvs moves back to kernel.org.
> >
> >commit 833656973cde30ba067a994c4802ebab6c9557ee
> >Author: Simon Horman <horms@verge.net.au>
> >Date:   Fri Sep 16 14:11:49 2011 +0900
> >
> >    ipvs: Remove unused return value of protocol state transitions
> >
> >    Acked-by: Julian Anastasov <ja@ssi.bg>
> >    Acked-by Hans Schillstrom <hans@schillstrom.com>
> >    Signed-off-by: Simon Horman <horms@verge.net.au>
> >    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> >
>=20
> >From what I can see Simon made a pull request and it was Acked by Pa=
blo 28 Sep
> http://www.spinics.net/lists/netfilter-devel/msg19742.html
>=20
> I have not seen any output to Miller yet...
> but I might be wrong in that case=20

Yes, it seems that Pablo has picked up the change but
it hasn't propagated to Dave's tree for one reason or another.

> >It wasn't there when I went about cleaning unused declaration of "cs=
".
> >I guess we have to make sure that everything between github (and
> >repositories there) and kernel.org repositories like Dave's "net-nex=
t"
> >align and holds water. Just by looking at some files, I can see that
> >"net-next" is missing some commits.
> >
> >KW
>=20
> Regards
> Hans
