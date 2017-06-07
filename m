From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: rps: send out pending IPI's on CPU hotplug
Date: Wed, 07 Jun 2017 13:04:14 -0400 (EDT)
Message-ID: <20170607.130414.522133678166859421.davem@davemloft.net>
References: <913335638b07570e5189713e1db9cbe6@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ashwanth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdFGREQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:04:16 -0400
In-Reply-To: <913335638b07570e5189713e1db9cbe6@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ashwanth@codeaurora.org
Date: Tue, 06 Jun 2017 20:47:36 +0530

> IPI's from the victim cpu are not handled in dev_cpu_callback.
> So these pending IPI's would be sent to the remote cpu only when
> NET_RX is scheduled on the victim cpu and since this trigger is
> unpredictable it would result in packet latencies on the remote cpu.
> 
> This patch adds support to send the pending ipi's of victim cpu.
> 
> Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>
> ---
>  net/core/dev.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fca407b..e6bfa54 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4948,6 +4948,19 @@ __sum16 __skb_gro_checksum_complete(struct
> sk_buff *skb)

This patch has been severely corrupted by your email client.

Please read Documentation/email-clients.txt, fix things up, send
a test email to yourself, and only resubmit this patch once you
are able yourself to successfully apply the patch that arrives
in that test email.

Thank you.
