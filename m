From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Fri, 27 May 2011 09:52:44 +0200
Message-ID: <201105270952.44811.a.miskiewicz@gmail.com>
References: <4DDE857E.40807@trash.net> <4DDE8814.7090201@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>
To: shemminger@osdl.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4DDE8814.7090201@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 of May 2011, Patrick McHardy wrote:
> Am 26.05.2011 18:53, schrieb Patrick McHardy:
> > The netfilter coreteam presents:
> >     iptables version 1.4.10
>=20
> That's supposed to read 1.4.11 of course :)

Too bad it breaks iproute2 build, hope to see fixed iproute2 release th=
en

gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -
DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\" -DCONFIG_GACT -DCONFIG_GACT=
_PROB -
DIPT_LIB_DIR=3D\"/usr/lib64/xtables\" -Wl,-export-dynamic -shared -fpic=
 -o=20
q_atm.so q_atm.c -latm
gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -
DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\" -DCONFIG_GACT -DCONFIG_GACT=
_PROB -
DIPT_LIB_DIR=3D\"/usr/lib64/xtables\" -Wl,-export-dynamic -shared -fpic=
 -o=20
m_xt.so m_xt.c -lxtables
m_xt.c: In function =E2=80=98parse_ipt=E2=80=99:
m_xt.c:167:31: warning: passing argument 2 of =E2=80=98xtables_merge_op=
tions=E2=80=99 discards=20
=E2=80=98const=E2=80=99 qualifier from pointer target type [enabled by =
default]
/usr/include/xtables.h:395:23: note: expected =E2=80=98struct option *=E2=
=80=99 but argument=20
is of type =E2=80=98const struct option *=E2=80=99
m_xt.c:167:31: warning: passing argument 3 of =E2=80=98xtables_merge_op=
tions=E2=80=99 from=20
incompatible pointer type [enabled by default]
/usr/include/xtables.h:395:23: note: expected =E2=80=98const struct opt=
ion *=E2=80=99 but=20
argument is of type =E2=80=98unsigned int *=E2=80=99
m_xt.c:167:31: error: too few arguments to function =E2=80=98xtables_me=
rge_options=E2=80=99
/usr/include/xtables.h:395:23: note: declared here
m_xt.c:127:6: warning: variable =E2=80=98res=E2=80=99 set but not used =
[-Wunused-but-set-
variable]
m_xt.c: In function =E2=80=98print_ipt=E2=80=99:
m_xt.c:312:30: warning: passing argument 2 of =E2=80=98xtables_merge_op=
tions=E2=80=99 discards=20
=E2=80=98const=E2=80=99 qualifier from pointer target type [enabled by =
default]
/usr/include/xtables.h:395:23: note: expected =E2=80=98struct option *=E2=
=80=99 but argument=20
is of type =E2=80=98const struct option *=E2=80=99
m_xt.c:312:30: warning: passing argument 3 of =E2=80=98xtables_merge_op=
tions=E2=80=99 from=20
incompatible pointer type [enabled by default]
/usr/include/xtables.h:395:23: note: expected =E2=80=98const struct opt=
ion *=E2=80=99 but=20
argument is of type =E2=80=98unsigned int *=E2=80=99
m_xt.c:312:30: error: too few arguments to function =E2=80=98xtables_me=
rge_options=E2=80=99
/usr/include/xtables.h:395:23: note: declared here
make[1]: *** [m_xt.so] B=C5=82=C4=85d 1
rm emp_ematch.lex.c emp_ematch.yacc.c


--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
