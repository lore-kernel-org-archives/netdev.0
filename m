From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] skbedit: allow the user to specify bitmask for mark
Date: Mon, 21 Jul 2014 14:31:42 +0200
Message-ID: <1405945902.10255.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:57388 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbaGUMbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 08:31:51 -0400
Received: by mail-we0-f176.google.com with SMTP id q58so7494345wes.7
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 05:31:48 -0700 (PDT)
In-Reply-To: <1405931720-24383-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-07-21 at 10:35 +0200, Antonio Quartulli wrote:
> From: Antonio Quartulli <antonio@open-mesh.com>
> 
> The user may want to use only some bits of the skb mark in
> his skbedit rules because the remaining part might be used by
> something else.
> 
> Introduce the "mask" parameter to the skbedit actor in order
> to implement such functionality.
> 
> When the mask is specified, only those bits selected by the
> latter are altered really changed by the actor, while the
> rest is left untouched.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> ---
>  include/net/tc_act/tc_skbedit.h        |  1 +
>  include/uapi/linux/tc_act/tc_skbedit.h |  2 ++
>  net/sched/act_skbedit.c                | 20 +++++++++++++++++---
>  3 files changed, 20 insertions(+), 3 deletions(-)


You forgot to update tcf_skbedit_dump()
