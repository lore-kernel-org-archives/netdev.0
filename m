From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH linux-firmware] qed: Add firmware 8.10.10.0
Date: Tue, 16 Aug 2016 11:14:20 -0400
Message-ID: <20160816151420.GA20731@merlin.infradead.org>
References: <1471357990-6255-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-firmware@kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58964 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbcHPPOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:14:22 -0400
Content-Disposition: inline
In-Reply-To: <1471357990-6255-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 05:33:10PM +0300, Yuval Mintz wrote:
> This new firmware for the qed* adpaters fixes several issues:
>  - Better blocking of malicious VFs.
>  - After FLR, Tx-switching [internal routing] of packets might
>    be incorrect.
>  - Deletion of unicast MAC filters would sometime have side-effect
>    of corrupting the MAC filters configred for a device.
> It also contains fixes for future qed* drivers that *hopefully* would be
> sent for review in the near future.
> 
> In addition, it would allow driver some new functionality, including:
>  - Allowing PF/VF driver compaitibility with old drivers [running
>    pre-8.10.5.0 firmware].
>  - Better debug facilities.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks Yuval.

--Kyle
