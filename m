From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 16183] New: sch_teql no longer works post 2.6.30
Date: Fri, 11 Jun 2010 19:43:30 +0200
Message-ID: <1276278210.2448.14.camel@edumazet-laptop>
References: <20100611090835.31b8436c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:46127 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755593Ab0FKRnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 13:43:40 -0400
Received: by wwb18 with SMTP id 18so982253wwb.19
        for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 10:43:38 -0700 (PDT)
In-Reply-To: <20100611090835.31b8436c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 11 juin 2010 =C3=A0 09:08 -0700, Stephen Hemminger a =C3=A9=
crit :
>=20
> Begin forwarded message:
>=20
> Date: Fri, 11 Jun 2010 15:56:44 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 16183] New: sch_teql no longer works post 2.6.30
>=20
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D16183
>=20
>            Summary: sch_teql no longer works post 2.6.30
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.31 through 2.6.34
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: tom@compton.nu
>         Regression: Yes
>=20
>=20
> Created an attachment (id=3D26729)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D26729)
> Patch to fix sch_teql
>=20
> The sch_teql module, which can be used to load balance over a set of =
underlying
> interfaces, stopped working after 2.6.30 and has been broken in all k=
ernels
> since then.
>=20
> The problem is that the transmit routine relies on being able to acce=
ss the
> destination address in the skb in order to do ARP resolution once it =
has
> decided which underlying interface it is going to transmit through.
>=20
> In 2.6.31 the IFF_XMIT_DST_RELEASE flag was introduced, and set by de=
fault for
> all interfaces, which causes the destination address to be release be=
fore the
> transmit routine for the interface is called.
>=20
> The solution (implemented in the attached patch) is to clear that fla=
g for teql
> interfaces.
>=20
> --=20
> Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=3Dem=
ail
> ------- You are receiving this mail because: -------
> You are the assignee for the bug.
>=20
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Please note my old email address no longer works ;)

Thanks


