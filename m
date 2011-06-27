From: "Toshiharu Okada" <toshiharu-linux@dsn.okisemi.com>
Subject: Re: [RFC 33/72] pch_gbe: Move the OKI driver
Date: Mon, 27 Jun 2011 10:53:57 +0900
Message-ID: <3B25EA73F6D1497783379086E3A18D6A@hacdom.okisemi.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-34-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "Tomoya" <tomoya-linux@dsn.okisemi.com>, <netdev@vger.kernel.org>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: <davem@davemloft.net>, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:14379 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755336Ab1F0ByG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 21:54:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jun 2011 06:58:44 -0700
>Move the OKI driver into driver/net/ethernet/oki/ and make the
>necessary Kconfig and Makefile changes.
>
>Note: there is no documented maintainer for this driver, so I CC'd
>the last 2 major contributors.
>
>CC: Tomoya <tomoya-linux@dsn.okisemi.com>
>CC: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>---
> drivers/net/Kconfig                                | 
>   19 -------------------
> drivers/net/Makefile                               |    1 -
> drivers/net/ethernet/Kconfig                       |    1 +
> drivers/net/ethernet/Makefile                      |    1 +
> drivers/net/ethernet/oki/Kconfig                   |   18 
> ++++++++++++++++++
> drivers/net/ethernet/oki/Makefile                  |    5 +++++
> drivers/net/ethernet/oki/pch_gbe/Kconfig           |   20 
> ++++++++++++++++++++
> drivers/net/{ => ethernet/oki}/pch_gbe/Makefile    |    0
> drivers/net/{ => ethernet/oki}/pch_gbe/pch_gbe.h   |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.c   |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_api.h   |    0
> .../{ => ethernet/oki}/pch_gbe/pch_gbe_ethtool.c   |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_main.c  |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_param.c |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.c   |    0
> .../net/{ => ethernet/oki}/pch_gbe/pch_gbe_phy.h   |    0

OKi semiconductor is a different company from OKI Groups.
Therefor please use not "/oki" but "/oki-semi"

Best Regards
Toshiharu Okada 

