From: "=?ISO-8859-1?Q?C=E9dric_Augonnet?=" <cedric.augonnet@gmail.com>
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Thu, 24 Jul 2008 17:57:16 +0200
Message-ID: <f56c1ba00807240857xd5b2e84q9c3fc9642fd68dc@mail.gmail.com>
References: <200807241534.m6OFYBmc029095@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Francois Romieu" <romieu@fr.zoreil.com>,
	"Mario Limonciello" <Mario_Limonciello@dell.com>,
	kernel@vger.kernel.org, netdev@vger.kernel.org,
	c4p7n1@capitanio.org
To: "martin capitanio" <martin@capitanio.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:36551 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbYGXP5R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 11:57:17 -0400
Received: by py-out-1112.google.com with SMTP id p76so2150029pyb.10
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 08:57:16 -0700 (PDT)
In-Reply-To: <200807241534.m6OFYBmc029095@post.webmailer.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

>        case RTL_GIGA_MAC_VER_04:
>                rtl8169sb_hw_phy_config(ioaddr);
>                break;
> +       case RTL_GIGA_MAC_VER_13:
> +       case RTL_GIGA_MAC_VER_16:
> +               rtl8101_hw_phy_config(ioaddr);

Should not there be a "break;" here or is it intended to go through
the next case as well?

>        case RTL_GIGA_MAC_VER_18:
>                rtl8168cp_hw_phy_config(ioaddr);
>                break;

Perhaps i missed something obvious, sorry if that's the case ...

Cheers,
C=E9dric
