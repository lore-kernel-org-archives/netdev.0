From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH 0/3] cnic fixes.
Date: Mon, 2 Jun 2014 17:08:49 -0700
Message-ID: <1401754129.6344.5.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
	 <20140602.165336.1418034972875163602.davem@davemloft.net>
	 <20140602.165728.1529037806527079682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:36060 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbaFCAIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 20:08:50 -0400
In-Reply-To: <20140602.165728.1529037806527079682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-02 at 16:57 -0700, David Miller wrote:=20
> From: David Miller <davem@davemloft.net>
> Date: Mon, 02 Jun 2014 16:53:36 -0700 (PDT)
>=20
> > From: Michael Chan <mchan@broadcom.com>
> > Date: Fri, 30 May 2014 16:18:40 -0700
> >=20
> >> Fix 2 sleeping function from invalid context bugs and 1 missing is=
csi netlink
> >> message bug.
> >=20
> > Series applied, thanks Michael.
>=20
> Michael, any chance you can compile test the changes you send to me?
>=20
> drivers/net/ethernet/broadcom/cnic.c: In function =CA=BDcnic_rcv_nete=
vent=CA=BC:
> drivers/net/ethernet/broadcom/cnic.c:5628:13: error: =CA=BDlockdep_is=
=CA=BC undeclared (first use in this function)
> drivers/net/ethernet/broadcom/cnic.c:5628:13: note: each undeclared i=
dentifier is reported only once for each function it appears in
> drivers/net/ethernet/broadcom/cnic.c:5628:13: error: expected =CA=BD)=
=CA=BC before =CA=BDheld=CA=BC

Sorry, I think LOCKDEP was not defined in my kernel.  I'll get it fixed
and resend the patches.
