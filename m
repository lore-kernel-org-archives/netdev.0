From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: sched: get rid of
 cls_flower->egress_dev
Date: Tue, 10 Oct 2017 23:13:57 +0200
Message-ID: <20171010211357.GJ2033@nanopsycho>
References: <20171010073016.3682-1-jiri@resnulli.us>
 <CAJ3xEMgPdcVrogHZmEnH+vP3E53zvEcFN8+wyuEqSs6utHQVRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:56598 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932616AbdJJVN7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:13:59 -0400
Received: by mail-wm0-f65.google.com with SMTP id l68so611972wmd.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 14:13:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgPdcVrogHZmEnH+vP3E53zvEcFN8+wyuEqSs6utHQVRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 10, 2017 at 07:24:21PM CEST, gerlitz.or@gmail.com wrote:
>Jiri,
>
>FWIW, as I reported to you earlier, I was playing with tc encap/decap rules
>on 4.14-rc+ (net) before
>applying any patch of this series, and something is messy w.r.t to decap
>rules. I don't see
>them removed at all when user space attempts to do so. It might (probably)
>mlx5 bug, which
>we will have to fix for net and later rebase net-next over net. We have
>short WW here so
>I will not be able to do RCA this week.

Or, as I replied to you earlier, the issue you describe is totally
unrelated to this patchset as you see the issue with the current net-next.
Not sure why you add this comment here.
