From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tg3: move init/deinit from open/close to
 probe/remove
Date: Mon, 12 Jan 2015 15:59:25 -0500 (EST)
Message-ID: <20150112.155925.821008820320410790.davem@davemloft.net>
References: <1420729987-18476-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, prashant@broadcom.com, mchan@broadcom.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbALU72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 15:59:28 -0500
In-Reply-To: <1420729987-18476-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu,  8 Jan 2015 16:13:07 +0100

> Move init and deinit of PTP support from open/close functions
> to probe/remove funcs to avoid removing/re-adding of associated PTP
> device(s) during ifup/ifdown.
> 
> v2: tg3_ptp_init call moved to correct place (thx. Prashant)
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thank you.
