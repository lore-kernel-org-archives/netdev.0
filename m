From: =?UTF-8?Q?Frank_Sch=c3=a4fer?= <fschaefer.oss@googlemail.com>
Subject: Re: [PATCH (net.git) 0/2] stmmac: MDIO fixes
Date: Wed, 9 Mar 2016 19:20:07 +0100
Message-ID: <56E06957.1070309@googlemail.com>
References: <1457514007-32333-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: gabriel.fernandez@linaro.org, afaerber@suse.de,
	dinh.linux@gmail.com, davem@davemloft.net
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35993 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933612AbcCISSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 13:18:24 -0500
Received: by mail-wm0-f54.google.com with SMTP id n186so191591943wmn.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 10:18:23 -0800 (PST)
In-Reply-To: <1457514007-32333-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 09.03.2016 um 10:00 schrieb Giuseppe Cavallaro:
> These two patches are to fix the recent regressions raised
> when test the stmmac on some platforms.
> Please I kindly ask you to give me the feedback if it actually
> covers all the cases and if the stmmac runs fine on the boxes.
> I have tested on my side the H410 B2120 with an embedded switch
> (so using the fixed-link).
>
> Giuseppe Cavallaro (2):
>   Revert "stmmac: Fix 'eth0: No PHY found' regression"
>   stmmac: fix MDIO settings
>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 ++-------
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   11 +++++++++-
>  .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   22 +++++--------------
>  include/linux/stmmac.h                             |    3 +-
>  4 files changed, 20 insertions(+), 27 deletions(-)
Works fine on the Banana Pi M1 board.
(Fixes "libphy: PHY stmmac-0:ffffffff not found")

Regards,
Frank
