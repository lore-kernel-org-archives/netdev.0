From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Delay during kdump load
Date: Wed, 29 Apr 2015 15:50:46 -0400 (EDT)
Message-ID: <20150429.155046.682475699031401071.davem@davemloft.net>
References: <1430284189-6773-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbbD2Tus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:50:48 -0400
In-Reply-To: <1430284189-6773-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 29 Apr 2015 08:09:49 +0300

> In a kdump environment interfaces might be re-loaded without a proper
> unload sequence in the previous running kernel.
> bnx2x management FW and driver maintains a `pulse' that notifies the FW
> that the driver is still up and running.
> 
> Driver load on the kdump kernel should be performed only after the pulse
> has been out-of-sync long enough for the management FW to identify that
> the driver has crashed, on which point it will perform some necessary
> cleanup of the HW.
> 
> In today's distros kdump loading is quite fast, sometimes too fast for our
> FW to get out-of-sync. This patch delays the bnx2x's probe during kdump
> to allow a proper re-load on the kdump kernel.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
