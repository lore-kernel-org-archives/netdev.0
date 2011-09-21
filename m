From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH v2 3/3] net/fec: add imx6q enet support
Date: Wed, 21 Sep 2011 08:07:42 -0300
Message-ID: <CAOMZO5CzVj=sMhD24H0OQKqp2Z0XtHhkTX=kEp5oshKqTAJ4oA@mail.gmail.com>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
	<1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	=?UTF-8?Q?Lothar_Wa=C3=9Fmann?= <LW@karo-electronics.de>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45821 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab1IULHn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 07:07:43 -0400
Received: by gyg10 with SMTP id 10so1016931gyg.19
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 04:07:43 -0700 (PDT)
In-Reply-To: <1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 8:10 AM, Shawn Guo <shawn.guo@linaro.org> wrote=
:
=2E..
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/eth=
ernet/freescale/Kconfig
> index 4dbe41f..1cf6716 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -7,7 +7,7 @@ config NET_VENDOR_FREESCALE
> =C2=A0 =C2=A0 =C2=A0 =C2=A0default y
> =C2=A0 =C2=A0 =C2=A0 =C2=A0depends on FSL_SOC || QUICC_ENGINE || CPM1=
 || CPM2 || PPC_MPC512x || \
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 M523x =
|| M527x || M5272 || M528x || M520x || M532x || \
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0IMX_H=
AVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC || \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ARCH_=
MXC || ARCH_MXS || \

Do you need to get rid of  IMX_HAVE_PLATFORM_FEC and MXS_HAVE_PLATFORM_=
=46EC?

By doing that you are selecting FEC for SoCs that don=C2=B4t have this
module such as MX1/MX21/MX31.

Regards,

=46abio Estevan
