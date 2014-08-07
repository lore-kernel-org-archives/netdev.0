From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] cxgb4: IEEE fixes for DCBx state machine
Date: Thu, 07 Aug 2014 16:19:07 -0700 (PDT)
Message-ID: <20140807.161907.762636102147198603.davem@davemloft.net>
References: <1407453243-8826-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaHGXTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:19:09 -0400
In-Reply-To: <1407453243-8826-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Thu,  7 Aug 2014 16:14:03 -0700

> * Changes required due to 16eecd9be4b05 ("dcbnl : Fix misleading
>   dcb_app->priority explanation")
> * Driver was previously not aware of what DCBx version was negotiated by
>   firmware, this could lead to DCB app table  in kernel or in firmware being
>   populated wrong  since IEEE/CEE used different formats made clear by above
>   mentioned commit
> * Driver was missing a couple of state transitions that could be caused
>   by other drivers that use chelsio hardware, resulting in incorrect behaviour
>   (the change that addresses this also flips the state machine to switch on
>    state instead of transition, hope this is okay in current window)
> * Prio queue info & tsa is no longer thrown away
> 
> v2: Print DCBx state transition messages only when debug is enabled
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

That looks better, applied, thanks.
