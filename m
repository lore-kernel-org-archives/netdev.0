From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: checkentry function
Date: Tue, 05 Oct 2010 14:07:42 +0200
Message-ID: <1286280462.2796.58.camel@edumazet-laptop>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
	 <20101005144615.0f84d53a@s6510>
	 <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com>
	 <20101005150147.62226282@s6510>
	 <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
	 <1286259838.2457.11.camel@edumazet-laptop>
	 <AANLkTinVtz0VuLkOY5d8QjdvLMXOFD2EaWp_kSBbMJBW@mail.gmail.com>
	 <alpine.LNX.2.01.1010051331550.4582@obet.zrqbmnf.qr>
	 <AANLkTim+5kETTN3sbo-woUAEN71woJb1eG9TX04tcyKW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTim+5kETTN3sbo-woUAEN71woJb1eG9TX04tcyKW@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 05 octobre 2010 =C3=A0 13:46 +0200, Nicola Padovano a =C3=A9cr=
it :
> On Tue, Oct 5, 2010 at 1:32 PM, Jan Engelhardt <jengelh@medozas.de> w=
rote:
> > On Tuesday 2010-10-05 13:16, Nicola Padovano wrote:
> >>>
> >>> Could you read source code of _current_ existing modules , and us=
e
> >>> copy/paste ?
> >>>
> >>> static int hashlimit_mt_check(const struct xt_mtchk_param *par)
> >>> {
> >>> ...
> >>> }
> >>
> >>as i've written in a previously mail this is the checkentry functio=
n
> >>that i use in my source code to check if the iptables command line =
is
> >>a right line.
> >>
> >>[CHECK_ENTRY_CODE]
> >>static bool xt_tarpit_check(const char *tablename, const void *entr=
y,
> >>                           const struct xt_target *target, void *ta=
rginfo,
> >>                           unsigned int hook_mask)
> >>
> >>i don't know what "static int hashlimit_mt_check(const struct
> >>xt_mtchk_param *par)" is...
> >
> > It's the proper function header.
> >
>=20
> this is the whole code:
>=20
> [WHOLE_CODE]

> [/WHOLE_CODE]
>=20

Nicola

=46or the second and last time, could you please _read_ _current_ kerne=
l
source code, and correct your code, before asking us ?

We do not support prehistoric kernels.

Thank you

Dont ask us if you are not able to find hashlimit_mt_check() or any
checkentry function in current kernel sources.

# find net/netfilter/ | xargs grep -n _check
net/netfilter/nf_conntrack_proto_dccp.c:596:	if (net->ct.sysctl_checksu=
m && hooknum =3D=3D NF_INET_PRE_ROUTING &&
net/netfilter/nf_conntrack_proto_dccp.c:597:	    nf_checksum_partial(sk=
b, hooknum, dataoff, cscov, IPPROTO_DCCP,
net/netfilter/xt_connmark.c:77:static int connmark_tg_check(const struc=
t xt_tgchk_param *par)
net/netfilter/xt_connmark.c:107:static int connmark_mt_check(const stru=
ct xt_mtchk_param *par)
net/netfilter/xt_connmark.c:127:	.checkentry     =3D connmark_tg_check,
net/netfilter/xt_connmark.c:138:	.checkentry     =3D connmark_mt_check,
net/netfilter/xt_CT.c:57:static int xt_ct_tg_check(const struct xt_tgch=
k_param *par)
net/netfilter/xt_CT.c:149:	.checkentry	=3D xt_ct_tg_check,
=2E..


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
