From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 net 0/2] Mellanox driver fixes
Date: Mon, 2 Mar 2015 18:44:51 +0200
Message-ID: <54F49383.9030905@mellanox.com>
References: <1425313336-28082-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0061.outbound.protection.outlook.com ([157.56.112.61]:14443
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754861AbbCBRCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 12:02:51 -0500
In-Reply-To: <1425313336-28082-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2015 6:22 PM, Or Gerlitz wrote:
> Hi Dave,
>
> Two small fixes, please apply to net.
>
> Both patches should go to 3.19.y too.
>
> thanks,
>
> Or.
>
> changes from V2:
>    - removed Gerrit IDs
s/from/for/
>
> changes from V1:
>    - applied feedback from Sergei
here too "for V1"
> Ido Shamay (1):
>    net/mlx4_en: Disbale GRO for incoming loopback/selftest packets
>
> Or Gerlitz (1):
>    net/mlx4_core: Fix wrong mask and error flow for the update-qp
>      command
>
>   drivers/net/ethernet/mellanox/mlx4/en_selftest.c   |    8 +++++++-
>   drivers/net/ethernet/mellanox/mlx4/qp.c            |    1 -
>   .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    9 ++++++---
>   include/linux/mlx4/qp.h                            |    2 +-
>   4 files changed, 14 insertions(+), 6 deletions(-)
>
