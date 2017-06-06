From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: rps: send out pending IPI's on CPU hotplug
Date: Tue, 06 Jun 2017 09:53:23 -0700
Message-ID: <1496768003.736.0.camel@edumazet-glaptop3.roam.corp.google.com>
References: <913335638b07570e5189713e1db9cbe6@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ashwanth@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35920 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdFFQxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:53:25 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so6294824pfd.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 09:53:25 -0700 (PDT)
In-Reply-To: <913335638b07570e5189713e1db9cbe6@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-06-06 at 20:47 +0530, ashwanth@codeaurora.org wrote:
> IPI's from the victim cpu are not handled in dev_cpu_callback.
> So these pending IPI's would be sent to the remote cpu only when
> NET_RX is scheduled on the victim cpu and since this trigger is
> unpredictable it would result in packet latencies on the remote cpu.
> 
> This patch adds support to send the pending ipi's of victim cpu.
> 
> Signed-off-by: Ashwanth Goli <ashwanth@codeaurora.org>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
