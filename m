From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed
 from lpfc driver
Date: Thu, 31 Jul 2014 13:11:31 -0700 (PDT)
Message-ID: <20140731.131131.187399848810031703.davem@davemloft.net>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, JBottomley@Parallels.com,
	james.smart@emulex.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaGaULb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 16:11:31 -0400
In-Reply-To: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 31 Jul 2014 22:08:37 +0200

> In prandom we have already reseeding mechanisms that trigger
> periodically from a much better entropy source than just
> feeding in jiffies through lpfc_mbx_cmpl_fcf_scan_read_fcf_rec()
> [what a function name 8-)]. Therefore, just remove this.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: James Bottomley <JBottomley@Parallels.com>
> Cc: James Smart <james.smart@emulex.com>
> ---
>  This can also go via James, how you prefer it.

James can pick this up, thanks.
