From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: constify qlcnic_mbx_ops structure
Date: Tue, 13 Oct 2015 04:18:59 -0700 (PDT)
Message-ID: <20151013.041859.2079956557358480044.davem@davemloft.net>
References: <1444564085-12839-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dept-GELinuxNICDev@qlogic.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47261 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932195AbbJMLDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 07:03:04 -0400
In-Reply-To: <1444564085-12839-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 11 Oct 2015 13:48:05 +0200

> The only instance of a qlcnic_mbx_ops structure is never modified.  Thus
> the declaration of the structure and all references to the structure type
> can be made const.
> 
> In the definition of the qlcnic_mailbox structure, the ops field is no
> longer lined up with the other fields.  This was left as is, to avoid a lot
> of trivial changes on the other lines.
> 
> Done with the help of Coccinelle.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks.
