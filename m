From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 00/25] [v2] netfilter updates for net-next (upcoming
 3.5)
Date: Tue, 8 May 2012 19:10:49 +0200
Message-ID: <20120508171049.GA16205@1984>
References: <1336463394-3119-1-git-send-email-pablo@netfilter.org>
 <20120508.124926.2241646617733136639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120508.124926.2241646617733136639.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2012 at 12:49:26PM -0400, David Miller wrote:
> From: pablo@netfilter.org
> Date: Tue,  8 May 2012 09:49:29 +0200
>=20
> > Second version including requested updates.
>=20
> There were lots of conflicts, due to my merge of net into net-next.
>=20
> Those were easy enough, but the result doesn't build.
>=20
> net/netfilter/nf_conntrack_helper.c: In function =E2=80=98nf_conntrac=
k_helper_init_sysctl=E2=80=99:
> net/netfilter/nf_conntrack_helper.c:65:2: error: implicit declaration=
 of function =E2=80=98register_net_sysctl_table=E2=80=99 [-Werror=3Dimp=
licit-function-declaration]
> net/netfilter/nf_conntrack_helper.c:66:4: error: =E2=80=98nf_net_netf=
ilter_sysctl_path=E2=80=99 undeclared (first use in this function)
> net/netfilter/nf_conntrack_helper.c:66:4: note: each undeclared ident=
ifier is reported only once for each function it appears in

Strange, this compiles here. Probably you have to add the following
include to net/netfilter/nf_conntrack_helper.c:

#include <net/net_namespace.h>

I can rebase all my patches on top of fresh tree, fix all conflicts
myself and send you another patchset that will apply to your current
tree.

Please, let me know how to proceed.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
