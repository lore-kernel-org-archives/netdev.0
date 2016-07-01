From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net_sched: fix mirrored packets checksum
Date: Fri, 1 Jul 2016 08:39:20 -0400
Message-ID: <57766478.6060707@mojatatu.com>
References: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:32963 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbcGAMjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 08:39:22 -0400
Received: by mail-io0-f177.google.com with SMTP id t74so99191110ioi.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 05:39:22 -0700 (PDT)
In-Reply-To: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 01:15 PM, Cong Wang wrote:
> Similar to commit 9b368814b336 ("net: fix bridge multicast packet checksum validation")
> we need to fixup the checksum for CHECKSUM_COMPLETE when
> pushing skb on RX path. Otherwise we get similar splats.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
