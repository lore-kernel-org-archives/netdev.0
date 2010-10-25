From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qlge: Restoring the vlan setting.
Date: Mon, 25 Oct 2010 12:07:39 -0700 (PDT)
Message-ID: <20101025.120739.104054830.davem@davemloft.net>
References: <1288023473-31490-1-git-send-email-ron.mercer@qlogic.com>
	<1288023473-31490-2-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jitendra.kalsaria@qlogic.com,
	ying.lok@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932837Ab0JYTHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:07:16 -0400
In-Reply-To: <1288023473-31490-2-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 25 Oct 2010 09:17:51 -0700

> +	if (qdev->vlgrp) {
> +		u16 vid;
> +			for (vid = 0; vid < VLAN_N_VID; vid++) {
> +				if (!vlan_group_get_device(qdev->vlgrp, vid))
> +					continue;
> +				qlge_vlan_rx_add_vid(qdev->ndev, vid);
> +			}
> +	}
> +}

Please fix the indentation in this code block.
