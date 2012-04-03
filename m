From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: xt_CT: remove a compile warning
Date: Tue, 03 Apr 2012 10:31:23 +0200
Message-ID: <1333441883.18626.60.camel@edumazet-glaptop>
References: <1333424902.18626.36.camel@edumazet-glaptop>
	 <20120403081728.GA19753@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46342 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab2DCIb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 04:31:28 -0400
Received: by bkcik5 with SMTP id ik5so3331077bkc.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 01:31:27 -0700 (PDT)
In-Reply-To: <20120403081728.GA19753@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 10:17 +0200, Pablo Neira Ayuso wrote:
> On Tue, Apr 03, 2012 at 05:48:22AM +0200, Eric Dumazet wrote:
> > If CONFIG_NF_CONNTRACK_TIMEOUT=3Dn we have following warning :
> >=20
> >   CC [M]  net/netfilter/xt_CT.o
> > net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=
=99:
> > net/netfilter/xt_CT.c:284: warning: label =E2=80=98err4=E2=80=99 de=
fined but not used
>=20
> Thanks Eric.
>=20
> I think I prefer the one attached.
>=20
> I 'll pass it to davem with a couple of other minor fixes anytime soo=
n.

Its your call, but you should move the whole

#if CONFIG_NF_CONNTRACK_TIMEOUT
	... lot of lines ...
#endif

in a helper function to make things a bit more maintainable
