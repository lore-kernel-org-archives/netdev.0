From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net RESEND] net: rps: send out pending IPI's on CPU
 hotplug
Date: Fri, 09 Jun 2017 15:35:15 -0400 (EDT)
Message-ID: <20170609.153515.1558177148048438064.davem@davemloft.net>
References: <1496998498-20836-1-git-send-email-ashwanth@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ashwanth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37916 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdFITfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:35:17 -0400
In-Reply-To: <1496998498-20836-1-git-send-email-ashwanth@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashwanth Goli <ashwanth@codeaurora.org>
Date: Fri,  9 Jun 2017 14:24:58 +0530

> IPI's from the victim cpu are not handled in dev_cpu_callback.
> So these pending IPI's would be sent to the remote cpu only when
> NET_RX is scheduled on the victim cpu and since this trigger is
> unpredictable it would result in packet latencies on the remote cpu.
> 
> This patch add support to send the pending ipi's of victim cpu.
> 
> Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>

Applied, thank you.
