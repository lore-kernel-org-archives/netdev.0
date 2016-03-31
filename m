From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: stop the "rcv is not +last, " error messages
Date: Thu, 31 Mar 2016 07:56:58 -0300
Message-ID: <CAOMZO5AfQrhjRErp+cCmcpn2qqjuPp0oNN9gaJp65A0o=p0DUQ@mail.gmail.com>
References: <56FB46EA.7050401@uclinux.org>
	<CAOMZO5B79aHocuqT4jgEU9gGcFYD5ZSDZh8PrGeXYAcLHW1x5Q@mail.gmail.com>
	<VI1PR0401MB1855458E0B31502D1C112AF6FF990@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Ungerer <gerg@uclinux.org>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36970 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbcCaK47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 06:56:59 -0400
Received: by mail-ig0-f169.google.com with SMTP id l20so64792555igf.0
        for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 03:56:59 -0700 (PDT)
In-Reply-To: <VI1PR0401MB1855458E0B31502D1C112AF6FF990@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Wed, Mar 30, 2016 at 10:41 PM, Fugang Duan <fugang.duan@nxp.com> wrote:
>
> Fabio, we cannot do it like this that may cause confused for the quirk flag "FEC_QUIRK_HAS_RACC".

We can treat FEC_QUIRK_HAS_RACC flag as "this is a non-Coldfire SoC".

>
>
> Hi, Greg,
>
> The header file fec.h define the FEC_FTRL as below,  if ColdFire SoC has no this register,  we may remove the define in here and define the register according to SOC type. For example, it is ColdFire Soc, define it as 0xFFF. Is it  feasible ?
>

This is even worse IMHO. We should not write to a 'fake' register
offset of 0xFFF.
