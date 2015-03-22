From: Priit Laes <plaes@plaes.org>
Subject: Re: [PATCH v2 0/4] rtlwifi: Use common functions for driver stats
Date: Sun, 22 Mar 2015 19:05:00 +0200
Message-ID: <1427043900.14656.2.camel@plaes.org>
References: <1427031320-10913-1-git-send-email-plaes@plaes.org>
	 <550EED87.8010008@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaoming Li <chaoming_li@realsil.com.cn>,
	Joe Perches <joe@perches.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from plaes.org ([188.166.43.21]:54682 "EHLO plaes.org"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751671AbbCVRFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Mar 2015 13:05:33 -0400
In-Reply-To: <550EED87.8010008@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-22 at 11:27 -0500, Larry Finger wrote:
> On 03/22/2015 08:35 AM, Priit Laes wrote:
> > Hi all,
> >=20
> > This is a small fixup to unify make the drivers use common helper
> > functions for driver statistics.
> >=20
> > There are no functional changes since the first posting, except=20
> > dropping
> > patches already applied and addressing the comments by Joe Perches.
>=20
> Are there patches that are required before these work? Applying=20
> these four=20
> results in the following build errors:

Oops. I'll figure out what went wrong.
>=20
> drivers/net/wireless/rtlwifi/rtl8192de/trx.c: In function=20
> =E2=80=98_rtl92de_query_rxphystatus=E2=80=99:
> drivers/net/wireless/rtlwifi/rtl8192de/trx.c:132:3: error: implicit=20
> declaration=20
> of function =E2=80=98rtl_query_rxpwrpercentage=E2=80=99 [-Werror=3Dim=
plicit-function-
> declaration]
>     pwdb_all =3D rtl_query_rxpwrpercentage(rx_pwr_all);
>     ^
> drivers/net/wireless/rtlwifi/rtl8192de/trx.c:192:4: error: implicit=20
> declaration=20
> of function =E2=80=98rtl_evm_db_to_percentage=E2=80=99 [-Werror=3Dimp=
licit-function-
> declaration]
>      evm =3D rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
>      ^
> drivers/net/wireless/rtlwifi/rtl8192de/trx.c:204:4: error: implicit=20
> declaration=20
> of function =E2=80=98rtl_signal_scale_mapping=E2=80=99 [-Werror=3Dimp=
licit-function-
> declaration]
>      (u8)(rtl_signal_scale_mapping(pwdb_all));
>      ^
> cc1: some warnings being treated as errors
> scripts/Makefile.build:258: recipe for target=20
> 'drivers/net/wireless/rtlwifi/rtl8192de/trx.o' failed
>=20
> I cannot find any patches that created common routines in rtlwifi.
>=20
> Larry
>=20
