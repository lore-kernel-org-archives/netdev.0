From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4 v3] bnx2x, cnic: support DRV_INFO upon FW
 request
Date: Tue, 06 Dec 2011 20:45:21 +0100
Message-ID: <1323200721.2690.22.camel@edumazet-laptop>
References: <1323160910-28446-1-git-send-email-mchan@broadcom.com>
	 <20111206.130654.1235461360535098349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mchan@broadcom.com, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33432 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab1LFTyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 14:54:21 -0500
Received: by eeaq14 with SMTP id q14so3294008eea.19
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2011 11:54:20 -0800 (PST)
In-Reply-To: <20111206.130654.1235461360535098349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 d=C3=A9cembre 2011 =C3=A0 13:06 -0500, David Miller a =C3=A9=
crit :
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 6 Dec 2011 00:41:50 -0800
>=20
> > From: Barak Witkowski <barak@broadcom.com>
> >=20
> > Add support to send driver capabilities, settings and statistics to
> > management firmware.
> >=20
> > [ Redone using many local variables, removed many unnecessary inlin=
es,
> >   and put #defines at the left margin suggested by Joe Perches ]
> >=20
> > Signed-off-by: Barak Witkowski <barak@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> > Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
>=20
> Applied.

Build error here if :

# grep CNIC .config
# CONFIG_CNIC is not set
# CONFIG_QLCNIC is not set


  CC [M]  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function
=E2=80=98bnx2x_drv_info_fcoe_stat=E2=80=99:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2950:33: erreur:
=E2=80=98struct bnx2x=E2=80=99 has no member named =E2=80=98fip_mac=E2=80=
=99
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function
=E2=80=98bnx2x_drv_info_iscsi_stat=E2=80=99:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3041:34: erreur:
=E2=80=98struct bnx2x=E2=80=99 has no member named =E2=80=98cnic_eth_de=
v=E2=80=99
