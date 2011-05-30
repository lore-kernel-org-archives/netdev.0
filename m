From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Mon, 30 May 2011 12:18:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1105301218200.11387@frira.zrqbmnf.qr>
References: <4DDE857E.40807@trash.net> <201105270952.44811.a.miskiewicz@gmail.com> <4DDF912A.5070003@netfilter.org> <201105301105.30036.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201105301105.30036.a.miskiewicz@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2011-05-30 11:05, Arkadiusz Miskiewicz wrote:

>On Friday 27 of May 2011, Pablo Neira Ayuso wrote:
>> On 27/05/11 09:52, Arkadiusz Miskiewicz wrote:
>
>> > /usr/include/xtables.h:395:23: note: expected =E2=80=98const struc=
t option *=E2=80=99 but
>> > argument is of type =E2=80=98unsigned int *=E2=80=99
>> > m_xt.c:312:30: error: too few arguments to function
>> > =E2=80=98xtables_merge_options=E2=80=99 /usr/include/xtables.h:395=
:23: note: declared
>> > here
>> > make[1]: *** [m_xt.so] B=C5=82=C4=85d 1
>> > rm emp_ematch.lex.c emp_ematch.yacc.c
>>=20
>> Backward compatibility was broken in the following iptables commit:
>>=20
>> From 600f38db82548a683775fd89b6e136673e924097 Mon Sep 17 00:00:00 20=
01
>> From: Jan Engelhardt <jengelh@medozas.de>
>> Date: Fri, 29 Oct 2010 18:57:42 +0200
>> Subject: [PATCH] libxtables: change option precedence order to be in=
tuitive
>
>Another bug seems to be in Makefile.am
>
>        for i in ${v4_bin_links}; do ${LN_S} -f "${sbindir}/iptables-m=
ulti"=20
>"${DESTDIR}${bindir}/$$i"; done;
>        for i in ${v4_sbin_links}; do ${LN_S} -f iptables-multi=20
>"${DESTDIR}${sbindir}/$$i"; done;
>        for i in ${v6_sbin_links}; do ${LN_S} -f ip6tables-multi=20
>"${DESTDIR}${sbindir}/$$i"; done;
>
>These will point to nowhere since now there is xtables-multi only.

Patch created yesterday already; now sent out.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
