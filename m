From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next (v2) 2/6] bnx2x: link cleanup
Date: Thu, 21 Jun 2012 10:06:25 -0700
Message-ID: <1340298385.29885.76.camel@joe2Laptop>
References: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
	 <1340255123-22371-3-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52625 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759857Ab2FURGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 13:06:25 -0400
In-Reply-To: <1340255123-22371-3-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 08:05 +0300, Yuval Mintz wrote:
> This patch does several things:
[]
>  3. Change msleep(small) --> usleep_range(small, small*2).
>     Also correct existing calls to usleep_range.

Just fyi:

There are some more of these duplicated arg
usleep_range uses in other files too

cheers, Joe

$ grep -rP --include=*.[ch] -n "\busleep_range\s*\(\s*(\w+)\s*,\s*\1\s*\)" drivers/net/ethernet/broadcom/bnx2x/
drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c:149:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:1167:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:1202:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:1631:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:1733:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:1763:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:7845:			usleep_range(1000,1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10571:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c:329:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c:1411:			usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:8308:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:8710:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:8741:		usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:8774:	usleep_range(1000, 1000);
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10463:				usleep_range(1000, 1000);
