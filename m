From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Utilize FW 7.13.1.0.
Date: Sun, 22 Nov 2015 12:19:17 -0500 (EST)
Message-ID: <20151122.121917.850044917970781029.davem@davemloft.net>
References: <1448197289-18906-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbKVRTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 12:19:19 -0500
In-Reply-To: <1448197289-18906-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 22 Nov 2015 15:01:29 +0200

> Commit 46e8a249423ff "bnx2x: Add FW 7.13.1.0" added said .bin FW to
> linux-firmware; This patch incorporates the FW in the bnx2x driver.
> 
> This introduces 2 fixes/enhancements:
>  - In some management protocols there are outer-vlan configurations
> that can be dynamically changed while device is running. This fixes
> some corner cases where such a change did not take effect.
> 
>  - Prevent VFs from sending MAC control frames; FW would treat a VF
> sending such a packet as malicious and block any further communication
> done by the VF.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied.
