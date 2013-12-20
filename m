From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net_sched: fix regression in tc_action_ops
Date: Fri, 20 Dec 2013 13:35:02 -0800
Message-ID: <CAM_iQpW8UnDoCiowCbYOGzK1pZoBi9SwEGTtnUrf3jXnZxyPBQ@mail.gmail.com>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
	<52B434FA.8080309@mojatatu.com>
	<1387550222.19078.434.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B45851.90208@mojatatu.com>
	<1387555659.19078.439.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560028.19078.442.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387560578.19078.443.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387562658.19078.448.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpUQ3iaq+X+CngqJCGWq5Ep_XhcfWEKqrCQcZ3iC6Uz_qA@mail.gmail.com>
	<1387568188.19078.453.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpV+WJdeOHOyGENT2XWn=ytjBirBo1G4H2b_QziKHWFw0g@mail.gmail.com>
	<1387570492.19078.463.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387571552.19078.468.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:44400 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343Ab3LTVfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 16:35:03 -0500
Received: by mail-oa0-f45.google.com with SMTP id o6so3489059oag.18
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 13:35:02 -0800 (PST)
In-Reply-To: <1387571552.19078.468.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 12:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> list_for_each_entry(a, &act_base, head) doesn't
> exit with a = NULL if we reached the end of the list.
>
> tcf_unregister_action(), tc_lookup_action_n() and tc_lookup_action()
> need fixes.
>
> Remove tc_lookup_action_id() as its unused and not worth 'fixing'

I even don't want to touch the #if 0 code block. :)

>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 1f747c26c48b ("net_sched: convert tc_action_ops to use struct list_head")
> Cc: Cong Wang <xiyou.wangcong@gmail.com>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
