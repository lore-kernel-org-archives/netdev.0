From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net-next 0/3] Ethtool support for phy stats
Date: Sun, 27 Dec 2015 12:07:15 -0800
Message-ID: <EEE79716-61A1-403E-826D-198C21667070@gmail.com>
References: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:33301 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbbL0UHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 15:07:21 -0500
Received: by mail-ob0-f170.google.com with SMTP id bx1so104439372obb.0
        for <netdev@vger.kernel.org>; Sun, 27 Dec 2015 12:07:21 -0800 (PST)
In-Reply-To: <1451217508-22276-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On December 27, 2015 3:58:25 AM PST, Andrew Lunn <andrew@lunn.ch> wrote:
>This patchset add ethtool support for reading statistics from the PHY.
>The Marvell and Micrel Phys are then extended to report receiver
>packet errors and idle errors.

Reviewed-by: Florian Fainelli <f.faibelli@gmail.com>

This is very useful, thanks! I like that you have introduced a separate interface rather than forcing the use of the existing get statistics method and then overlaying PHY stats to the existing MAC stats, this is just cleaner.

>
>v2:
>  Fix linking when phylib is not enabled.
>
>Andrew Lunn (3):
>  ethtool: Add phy statistics
>  phy: marvell: Add ethtool statistics counters
>  phy: micrel: Add ethtool statistics counters
>
>drivers/net/phy/marvell.c    | 135
>+++++++++++++++++++++++++++++++++++++++++++
> drivers/net/phy/micrel.c     |  96 ++++++++++++++++++++++++++++++
> drivers/net/phy/phy.c        |  35 +++++++++++
> include/linux/phy.h          |  11 +++-
> include/uapi/linux/ethtool.h |   3 +
> net/core/ethtool.c           |  57 +++++++++++++++++-
> 6 files changed, 335 insertions(+), 2 deletions(-)


-- 
Florian
