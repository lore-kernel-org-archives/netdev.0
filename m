From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next 0/3] cxgb4/cxgb4vf: Adds support for Chelsio T6
 adapter
Date: Tue, 2 Jun 2015 08:44:18 +0530
Message-ID: <20150602031415.GA9975@hariprasad-pc>
References: <1433206925-5997-1-git-send-email-hariprasad@chelsio.com>
 <20150601.170321.642455610763862859.davem@davemloft.net>
 <20150601.170429.598715578874417987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25761 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754931AbbFBDOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 23:14:23 -0400
Content-Disposition: inline
In-Reply-To: <20150601.170429.598715578874417987.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 17:04:29 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 01 Jun 2015 17:03:21 -0700 (PDT)
>=20
> > From: Hariprasad Shenai <hariprasad@chelsio.com>
> > Date: Tue,  2 Jun 2015 06:32:02 +0530
> >=20
> >> This patch series adds the following:
> >> Adds NIC driver support for T6 adapter
> >> Adds vNIC driver support for T6 adapter
> >>=20
> >> This patch series has been created against net-next tree and inclu=
des
> >> patches on cxgb4 and cxgb4vf driver.
> >>=20
> >> We have included all the maintainers of respective drivers. Kindly=
 review
> >> the change and let us know in case of any review comments.
> >=20
> > Series applied, thanks.
>=20
> Actually, reverted, this doesn't even compile.
>=20
> kernel/Makefile:135: *** No X.509 certificates found ***
> drivers/net/ethernet/chelsio/cxgb4/sge.c: In function =E2=80=98cxgb_f=
coe_offload=E2=80=99:
> drivers/net/ethernet/chelsio/cxgb4/sge.c:1128:5: error: expected iden=
tifier or =E2=80=98(=E2=80=99 before =E2=80=98}=E2=80=99 token
>  u64 }
>      ^
> drivers/net/ethernet/chelsio/cxgb4/sge.c:1128:1: warning: ISO C90 for=
bids mixed declarations and code [-Wdeclaration-after-statement]
>  u64 }
>  ^

My bad. Will send a V2 for the same.
