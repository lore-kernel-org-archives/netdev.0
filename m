From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlge: Fix qlge_update_hw_vlan_features to handle
 if interface is down
Date: Mon, 02 Feb 2015 17:51:35 -0800 (PST)
Message-ID: <20150202.175135.299745251563275368.davem@davemloft.net>
References: <10e24de024f81e60ab64a6f0bf9647d27eb40be1.1422618157.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harish.patil@qlogic.com, cdupuis@redhat.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933385AbbBCBvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 20:51:35 -0500
In-Reply-To: <10e24de024f81e60ab64a6f0bf9647d27eb40be1.1422618157.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Fri, 30 Jan 2015 09:56:01 -0200

> Currently qlge_update_hw_vlan_features() will always first put the
> interface down, then update features and then bring it up again. But it
> is possible to hit this code while the adapter is down and this causes a
> non-paired call to napi_disable(), which will get stuck.
> 
> This patch fixes it by skipping these down/up actions if the interface
> is already down.
> 
> Fixes: a45adbe8d352 ("qlge: Enhance nested VLAN (Q-in-Q) handling.")
> Cc: Harish Patil <harish.patil@qlogic.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Applied and queued up for -stable, thanks.
