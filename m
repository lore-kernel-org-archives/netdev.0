From: Kevin Curtis <Kevin.Curtis-AP8L3A0T/wRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all
 headers before an ethernet header
Date: Thu, 22 Nov 2012 08:12:38 +0000
Message-ID: <E603DC592C92B54A89CEF6B0919A0B1CA7D5A6CC87@SOLO.hq.farsitecommunications.com>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
 <1353499919-28596-10-git-send-email-ordex@autistici.org>
 <20121121.125759.322762083309845086.davem@davemloft.net>
 <8108710.8oNxxR0rRd@sven-laptop.home.narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org" <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org" <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>,
 "rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org" <rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>,
 "ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <ron.mercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "lindner_marek-LWAfsSFWpa4@public.gmane.org" <lindner_marek-LWAfsSFWpa4@public.gmane.org>,
 "jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org" <jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
 "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <8108710.8oNxxR0rRd-S/pmIDWWJIwhrEaHGRlFQnOel7F/LzPIcbWoRP8EXgk@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

>> Agree. But we should get this message also to the other guys

What message would this be?
Are you advocating a different use of #pragma pack()?


Kevin Curtis
Linux Development
FarSite Communications Ltd http://www.farsite.com
Winner of The Queen's Award for Enterprise 2009
tel:=A0 +44 1256 330461
fax:=A0 +44 1256 854931



-----Original Message-----
From: Sven Eckelmann [mailto:sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org]=20
Sent: 21 November 2012 18:20
To: David Miller
Cc: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; b.a.t.m.a.n-ZwoEplunGu2QeL92YiVCHQ@public.gmane.org=
h.org; lindner_marek-LWAfsSFWpa4@public.gmane.org; Kevin Curtis; linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org; ron.m=
ercer-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org; jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org; rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org; andy@gre=
yhouse.net; fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: Re: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all headers b=
efore an ethernet header

On Wednesday 21 November 2012 12:57:59 David Miller wrote:
> From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
> Date: Wed, 21 Nov 2012 13:11:59 +0100
>=20
> > +#pragma pack(2)
>=20
>  ...
>=20
> > -} __packed;
>=20
> The __packed attribute is an abstraction of the actual syntax the=20
> compiler uses, if it is supported at all.
>=20
> Therefore, you can't just unconditionally use the #pragma, and you=20
> would need to use some kind of similar compiler abstraction for it.
>=20
> But to be honest this is really ugly and for very little, if any,=20
> gain.

Agree. But we should get this message also to the other guys

$ git grep pragma -- drivers/net
drivers/net/bonding/bond_3ad.h:#pragma pack(1) drivers/net/bonding/bond_3ad=
.h:#pragma pack() drivers/net/bonding/bond_3ad.h:#pragma pack(8) drivers/ne=
t/bonding/bond_3ad.h:#pragma pack() drivers/net/bonding/bond_alb.c:#pragma =
pack(1) drivers/net/bonding/bond_alb.c:#pragma pack() drivers/net/ethernet/=
brocade/bna/bfa_defs.h:#pragma pack(1) drivers/net/ethernet/brocade/bna/bfa=
_defs.h:#pragma pack() drivers/net/ethernet/brocade/bna/bfa_defs_cna.h:#pra=
gma pack(1) drivers/net/ethernet/brocade/bna/bfa_defs_cna.h:#pragma pack() =
drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h:#pragma pack(1) driver=
s/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h:#pragma pack() drivers/net/e=
thernet/brocade/bna/bfi.h:#pragma pack(1) drivers/net/ethernet/brocade/bna/=
bfi.h:#pragma pack() drivers/net/ethernet/brocade/bna/bfi_cna.h:#pragma pac=
k(1) drivers/net/ethernet/brocade/bna/bfi_cna.h:#pragma pack() drivers/net/=
ethernet/brocade/bna/bfi_enet.h:#pragma pack(1) drivers/net/ethernet/brocad=
e/bna/bfi_enet.h:#pragma pack() drivers/net/ethernet/brocade/bna/cna.h:#pra=
gma pack(1) drivers/net/ethernet/brocade/bna/cna.h:#pragma pack() drivers/n=
et/ethernet/qlogic/qla3xxx.h:#pragma pack(1) drivers/net/ethernet/qlogic/ql=
a3xxx.h:#pragma pack() drivers/net/wan/farsync.c:#pragma pack(1) drivers/ne=
t/wan/farsync.c:#pragma pack()

Kind regards,
	Sven
