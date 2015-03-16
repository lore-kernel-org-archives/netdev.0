From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix encapsulation features on 57710/57711
Date: Mon, 16 Mar 2015 17:06:04 -0400 (EDT)
Message-ID: <20150316.170604.832941070614134507.davem@davemloft.net>
References: <1426518959-17883-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Dmitry.Kravkov@qlogic.com, Ariel.Elior@qlogic.com,
	erent@skyatlas.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbbCPVKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 17:10:55 -0400
In-Reply-To: <1426518959-17883-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Mon, 16 Mar 2015 16:15:59 +0100

> E1x chips (57710, 57711(E)) have no support for encapsulation
> offload. bnx2x incorrectly advertises the support as available.
> 
> Setting of those features is conditional on "!CHIP_IS_E1x(bp)", but
> the bp struct is not initialized yet at this point and consequently
> any chip passes the check.
> The check must use the "chip_is_e1x" local variable instead to work
> correctly.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks a lot Michal.
