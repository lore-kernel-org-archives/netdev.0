From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH v2 0/4] rtlwifi: Use common functions for driver stats
Date: Sun, 22 Mar 2015 11:27:51 -0500
Message-ID: <550EED87.8010008@lwfinger.net>
References: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Joe Perches <joe@perches.com>
To: Priit Laes <plaes@plaes.org>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:34819 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbCVQ1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 12:27:54 -0400
In-Reply-To: <1427031320-10913-1-git-send-email-plaes@plaes.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2015 08:35 AM, Priit Laes wrote:
> Hi all,
>
> This is a small fixup to unify make the drivers use common helper
> functions for driver statistics.
>
> There are no functional changes since the first posting, except dropp=
ing
> patches already applied and addressing the comments by Joe Perches.

Are there patches that are required before these work? Applying these f=
our=20
results in the following build errors:

drivers/net/wireless/rtlwifi/rtl8192de/trx.c: In function=20
=91_rtl92de_query_rxphystatus=92:
drivers/net/wireless/rtlwifi/rtl8192de/trx.c:132:3: error: implicit dec=
laration=20
of function =91rtl_query_rxpwrpercentage=92 [-Werror=3Dimplicit-functio=
n-declaration]
    pwdb_all =3D rtl_query_rxpwrpercentage(rx_pwr_all);
    ^
drivers/net/wireless/rtlwifi/rtl8192de/trx.c:192:4: error: implicit dec=
laration=20
of function =91rtl_evm_db_to_percentage=92 [-Werror=3Dimplicit-function=
-declaration]
     evm =3D rtl_evm_db_to_percentage(p_drvinfo->rxevm[i]);
     ^
drivers/net/wireless/rtlwifi/rtl8192de/trx.c:204:4: error: implicit dec=
laration=20
of function =91rtl_signal_scale_mapping=92 [-Werror=3Dimplicit-function=
-declaration]
     (u8)(rtl_signal_scale_mapping(pwdb_all));
     ^
cc1: some warnings being treated as errors
scripts/Makefile.build:258: recipe for target=20
'drivers/net/wireless/rtlwifi/rtl8192de/trx.o' failed

I cannot find any patches that created common routines in rtlwifi.

Larry
