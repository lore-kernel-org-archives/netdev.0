From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: limit fw delay in kdump to 5s after boot
Date: Sun, 10 May 2015 19:23:48 -0400 (EDT)
Message-ID: <20150510.192348.2013892438337765373.davem@davemloft.net>
References: <1431023830-445-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbbEJXXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 19:23:50 -0400
In-Reply-To: <1431023830-445-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu,  7 May 2015 20:37:10 +0200

> Commit 12a8541d5c82 "bnx2x: Delay during kdump load" added a 5 seconds
> delay to bnx2x's probe function in the kdump case to let the firmware
> realize the old driver is gone.
> 
> The problem with the delay is that it is per-device, so if you have
> several bnx2x NICs in NPAR mode, the delays can accumulate to minutes.
> 
> Fix it by adjusting the delay so that we do not wait more than
> necessary, i.e. no more delaying after 5 seconds of kernel boot time.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks.
