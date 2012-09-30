From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH net-next 0/2] bnx2x: net-next FW upgrade
Date: Sun, 30 Sep 2012 08:16:22 +0200
Message-ID: <5067E3B6.8050703@broadcom.com>
References: <1348757936-10262-1-git-send-email-yuvalmin@broadcom.com>
 <20120930.022836.251638342830809918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: "David Miller" <davem@davemloft.net>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4989 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab2I3GoY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2012 02:44:24 -0400
In-Reply-To: <20120930.022836.251638342830809918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> These patches do not build.
>=20
> drivers/net/ethernet/broadcom/cnic.c: In function =A1cnic_init_bnx2x_=
tx_ring=A2:
> drivers/net/ethernet/broadcom/cnic.c:4904:4: error: =A1ETH_TX_START_B=
D_ETH_ADDR_TYPE_SHIFT=A2 undeclared (first use in this function)
> drivers/net/ethernet/broadcom/cnic.c:4904:4: note: each undeclared id=
entifier is reported only once for each function it appears in
> make[4]: *** [drivers/net/ethernet/broadcom/cnic.o] Error 1
> make[4]: *** Waiting for unfinished jobs....
> make[3]: *** [drivers/net/ethernet/broadcom] Error 2
> make[2]: *** [drivers/net/ethernet] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Sorry about that - the HSI has changed which affects cnic as well as bn=
x2x.

A revised patch series which will advance both into the new FW will be =
submitted soon.
