From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 v2 repost 1/3] tc_filter: add support for chain
 index
Date: Fri, 26 May 2017 17:11:37 -0700
Message-ID: <20170526171137.0acccbc5@xeon-e3>
References: <20170516172802.1317-1-jiri@resnulli.us>
        <20170516172937.1391-1-jiri@resnulli.us>
        <20170522133315.3490fe0a@xeon-e3>
        <20170523134042.GC1829@nanopsycho>
        <59288675.4040009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33418 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948874AbdE0ALl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 20:11:41 -0400
Received: by mail-pg0-f44.google.com with SMTP id u187so358373pgb.0
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 17:11:41 -0700 (PDT)
In-Reply-To: <59288675.4040009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 May 2017 21:48:05 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/23/2017 03:40 PM, Jiri Pirko wrote:
> > Mon, May 22, 2017 at 10:33:15PM CEST, stephen@networkplumber.org wrote:=
 =20
> [...]
> >> Applied to net-next branch of iproute2 =20
> >
> > Looks like you missed the uapi part:
> >
> >      CC       tc_filter.o
> > tc_filter.c: In function =E2=80=98tc_filter_modify=E2=80=99:
> > tc_filter.c:159:34: error: =E2=80=98TCA_CHAIN=E2=80=99 undeclared (firs=
t use in this function)
> >     addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_index);
> >                                    ^~~~~~~~~ =20
>=20
> Looks like still unresolved in the iproute2 -net-next branch ...

On the net-next branch include/linux/rtnetlink.h now has TCA_CHAIN, and eve=
rything
builds fine.  You may have local changes or be using different includes

$ git grep TCA_CHAIN
include/linux/rtnetlink.h:      TCA_CHAIN,
tc/tc_filter.c:         addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_ind=
ex);
tc/tc_filter.c: if (tb[TCA_CHAIN]) {
tc/tc_filter.c:         __u32 chain_index =3D rta_getattr_u32(tb[TCA_CHAIN]=
);
tc/tc_filter.c:         addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_ind=
ex);
tc/tc_filter.c:         addattr32(&req.n, sizeof(req), TCA_CHAIN, chain_ind=
ex);
