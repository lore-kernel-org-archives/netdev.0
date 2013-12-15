From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/8] b44: cheek register instead of PHY address to detect
 external PHY
Date: Sun, 15 Dec 2013 23:04:12 +0300
Message-ID: <52AE0B3C.1040107@cogentembedded.com>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de> <1387132925-18651-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:39006 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3LOTEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 14:04:14 -0500
Received: by mail-la0-f44.google.com with SMTP id ep20so2378473lab.31
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 11:04:12 -0800 (PST)
In-Reply-To: <1387132925-18651-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/15/2013 09:41 PM, Hauke Mehrtens wrote:

    s/cheek/check/ in the subject. :-)

> The Ethernet core supported by b44 supports an internal PHY integrated
> into the mac core, which is supported by the b44 driver and an external
> PHY to which the mac core is connected. This external PHY could be a
> switch connected through MII, which is often the case when this core is
> used on home routers. The usage of an external PHY was assumed when the
> PHY address 30 was used and an internal PHY was assumed when the PHY
> address was different. To verify that b44_phy_reset() was called and
> checked if it worked, otherwise PHY address 30 was assumed, an external
> PHY. It is better to check the register which says which PHY is
> connected to the MAC instead of checking the PHY address.

> This also changes B44_FLAG_INTERNAL_PHY to B44_FLAG_EXTERNAL_PHY, it is
> easier to check.

> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

WBR, Sergei
