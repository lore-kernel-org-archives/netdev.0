From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, net-next] r8169:Actually from r810x_pll_power_up
Date: Wed, 26 Aug 2015 23:13:58 +0200
Message-ID: <20150826211358.GA14167@electric-eye.fr.zoreil.com>
References: <1440594505-2908-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37338 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbHZVOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 17:14:22 -0400
Content-Disposition: inline
In-Reply-To: <1440594505-2908-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
> Actually from r810x_pll_power_up function i removed function
>   r810x_phy_power_up because is two situation.One run from  rtl8169_p=
hy_reset
>  wich already power on interface after reset MII_BMCR  and two i plac=
ed
>  supplementary on __rtl8169_resume.

r810x_phy_power_up and r810x_pll_power_up are dedicated to 810x chipset=
s.

__rtl8169_resume is used by all chipsets.


--=20
Ueimor

C'est syst=C3=A9matiquement d=C3=A9bile mais c'est toujours inattendu.
