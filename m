From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: Re: [ANNOUNCE] ipset-4.4 released
Date: Sat, 2 Oct 2010 12:39:43 -0300
Message-ID: <AANLkTi=_8OTmnWv628ho6q-=KrMJe5iUDCtA0zPC9Vsx@mail.gmail.com>
References: <alpine.DEB.2.00.1010012214250.19669@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49232 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab0JBPjq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 11:39:46 -0400
Received: by bwz11 with SMTP id 11so2789207bwz.19
        for <netdev@vger.kernel.org>; Sat, 02 Oct 2010 08:39:44 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1010012214250.19669@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks so much,

I was just facing that very same problem of mixed src,dst with ipportip=
hash.

Christophe

On Fri, Oct 1, 2010 at 6:02 PM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
> Hi,
>
> ipset-4.4 has just been released with one important fix and some smal=
l
> corrections:
>
> Kernel part changes:
> =A0- The ipporthash, ipportiphash and ipportnethash set types did
> =A0 =A0not work with mixed "src" and "dst" direction parameters of th=
e "set"
> =A0 =A0and =A0"SET" iptables match and target (reported by Dash Four)
> =A0- Errorneous semaphore handling in error path fixed (reported by
> =A0 =A0Jan Engelhardt, bugzilla id 668)
>
> Userspace changes:
> =A0 - Manpage fix to make it clear how ipset works on setlist type
> =A0 =A0 of sets (John Brendler, bugzilla id 640)
>
> Please note, if you use ipporthash, ipportiphash or ipportnethash typ=
e of
> sets with mixed direction parameters of the "set" and "SET" iptables =
match
> and target, then you must upgrade.
>
> You can download the new version from the usual places:
> =A0 =A0 =A0 =A0http://ipset.netfilter.org
> =A0 =A0 =A0 =A0git://git.netfilter.org/ipset.git
>
> Best regards,
> Jozsef
> -
> E-mail =A0: kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
> PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
> Address : KFKI Research Institute for Particle and Nuclear Physics
> =A0 =A0 =A0 =A0 =A0H-1525 Budapest 114, POB. 49, Hungary
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
