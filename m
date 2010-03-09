From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Tue, 09 Mar 2010 18:09:28 +0100
Message-ID: <1268154568.3113.19.camel@edumazet-laptop>
References: <119601268120674@webmail87.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:64152 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755103Ab0CIRJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 12:09:33 -0500
Received: by bwz1 with SMTP id 1so4100131bwz.21
        for <netdev@vger.kernel.org>; Tue, 09 Mar 2010 09:09:32 -0800 (PST)
In-Reply-To: <119601268120674@webmail87.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 mars 2010 =C3=A0 10:44 +0300, "Oleg A. Arkhangelsky" a =C3=A9=
crit :
> Hello,
>=20
> Got this kernel panic tomorrow. This PC is rather heavy loaded router=
 with BGP full view (> 300K routes).
> We're using FIB_TRIE. Last time we got similar panic about 1 month ag=
o. Please, let me know if you
> need additional information to debug (e.g. objdump). Thanks!
>=20
> Mar  9 10:08:55 bras-1 kernel: BUG: unable to handle kernel NULL poin=
ter dereference at (null)
> Mar  9 10:08:55 bras-1 kernel: IP: [<c11fa012>] fib_rules_lookup+0xa2=
/0xd0
> Mar  9 10:08:55 bras-1 kernel: *pde =3D 00000000
> Mar  9 10:08:55 bras-1 kernel: Thread overran stack, or stack corrupt=
ed

Hmm...

> Mar  9 10:08:55 bras-1 kernel: Oops: 0000 [#1] SMP
> Mar  9 10:08:55 bras-1 kernel: Modules linked in: ipt_NETFLOW iTCO_wd=
t xt_tcpudp iptable_filter iptable_nat ip_tables ipt_ISG x_tables ipmi_=
watchdog ipmi_msghandler nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_=
ipv4 nf_conntrack_ftp nf_conntrack 8021q e1000 e1000e
> Mar  9 10:08:55 bras-1 kernel:
> Mar  9 10:08:55 bras-1 kernel: Pid: 0, comm: swapper Not tainted (2.6=
=2E32 #3)

Is it an unpatched kernel ?

Could you send us your .config ?

gcc -v ?


