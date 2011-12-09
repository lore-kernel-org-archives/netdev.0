From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: netprio_cgroup: make net_prio_subsys
 static
Date: Fri, 09 Dec 2011 17:05:04 +0100
Message-ID: <1323446704.2336.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
	 <20111208114555.GA1246@hmsreliant.think-freely.org>
	 <20111208.195339.152346047030004418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48761 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab1LIQFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 11:05:08 -0500
Received: by bkbzv3 with SMTP id zv3so3031894bkb.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 08:05:07 -0800 (PST)
In-Reply-To: <20111208.195339.152346047030004418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 d=C3=A9cembre 2011 =C3=A0 19:53 -0500, David Miller a =C3=A9=
crit :
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 8 Dec 2011 06:45:55 -0500
>=20
> > On Wed, Dec 07, 2011 at 09:17:17PM -0800, John Fastabend wrote:
> >> net_prio_subsys can be made static this removes the sparse
> >> warning it was throwing.
> >>=20
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>  ...
> > Acked-by: Neil Horman <nhorman@tuxdriver.com>
>=20
> Applied.
> --

But it trivialy breaks the build ? Or am I mistaken ?


$ grep CONFIG_NETPRIO_CGROUP .config
CONFIG_NETPRIO_CGROUP=3Dy

$ make net/core/netprio_cgroup.o
  CC      net/core/netprio_cgroup.o
net/core/netprio_cgroup.c:31:29: error: static declaration of =E2=80=98=
net_prio_subsys=E2=80=99 follows non-static declaration
include/linux/cgroup_subsys.h:71:1: note: previous declaration of =E2=80=
=98net_prio_subsys=E2=80=99 was here
make[1]: *** [net/core/netprio_cgroup.o] Error 1
make: *** [net/core/netprio_cgroup.o] Error 2
