From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 0/2] Add support for tc cookies
Date: Tue, 17 Jan 2017 13:17:46 +0100
Message-ID: <20170117121746.GD1807@nanopsycho.orion>
References: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35186 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdAQMRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 07:17:50 -0500
Received: by mail-wm0-f65.google.com with SMTP id d140so21652514wmd.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 04:17:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484651509-27500-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 17, 2017 at 12:11:47PM CET, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>

No reason to bundle the stylistics cleanup patch with the act cookie
patch. Just send it as 2 separate patches they are.


>
>Changes in v4:
> - move stylistic changes out into a separate patch
>   (and add more stylistic changes)
>
>Changes in v3:
> - use TC_ prefix for the max size
> - move the cookie struct so visible only to kernel
> - remove unneeded void * cast
>
>Changes in V2:
> -move from a union to a length-value representation
>
>Jamal Hadi Salim (2):
>  net sched actions: Add support for user cookies
>  net sched: Trivial whitespace and stylistic changes
>
> include/net/act_api.h        |  8 ++++---
> include/net/pkt_cls.h        | 53 ++++++++++++++++++++++----------------------
> include/uapi/linux/pkt_cls.h |  3 +++
> net/sched/act_api.c          | 45 +++++++++++++++++++++++++++----------
> 4 files changed, 67 insertions(+), 42 deletions(-)
>
>-- 
>1.9.1
>
