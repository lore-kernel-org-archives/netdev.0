From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v2] net: Fix unused variable compile warning
Date: Wed, 7 Oct 2015 10:02:40 +0900
Message-ID: <20151007010237.GD21067@verge.net.au>
References: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
 <CAHA+R7PTyS=wtowhKZ4osDs_VF=UJvfhw_xkWO3PQZuiFdnTsw@mail.gmail.com>
 <20151005.233537.1854084467334631982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: cwang@twopensource.com, dsa@cumulusnetworks.com,
	netdev@vger.kernel.org, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41104 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbJGBCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 21:02:36 -0400
Content-Disposition: inline
In-Reply-To: <20151005.233537.1854084467334631982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 05, 2015 at 11:35:37PM -0700, David Miller wrote:
> From: Cong Wang <cwang@twopensource.com>
> Date: Mon, 5 Oct 2015 10:53:57 -0700
>=20
> > On Thu, Oct 1, 2015 at 8:49 AM, David Ahern <dsa@cumulusnetworks.co=
m> wrote:
> >> Eric's net namespace changes in 1b75097dd7a26 leaves net unreferen=
ced if
> >> CONFIG_IP_VS_IPV6 is not enabled:
> >>
> >> ../net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=
=E2=80=99:
> >> ../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variab=
le =E2=80=98net=E2=80=99 [-Wunused-variable]
> >>
> >> After the net refactoring there is only 1 user; push the reference=
 to the
> >> 1 user. While the line length slightly exceeds 80 it seems to be t=
he
> >> best change.
> >>
> >> Fixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
> >> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> >=20
> > I saw the same build warning, and this fix looks good to me.
> >=20
> > DaveM, can you take this?
>=20
> It should be submitted to netfilter-devel and Pablo should take it.

lvs-devel would be better yet.
I submitted an identical patch there yesterday.

I'll pick up David's version and send it to Pablo ASAP.
