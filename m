From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched/hfsc: fix curve activation in
 hfsc_change_class()
Date: Thu, 21 Sep 2017 11:57:59 -0700 (PDT)
Message-ID: <20170921.115759.1923847665880486763.davem@davemloft.net>
References: <150591157194.113686.4485981339195559372.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52784 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdIUS6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:58:00 -0400
In-Reply-To: <150591157194.113686.4485981339195559372.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Wed, 20 Sep 2017 15:46:11 +0300

> If real-time or fair-share curves are enabled in hfsc_change_class()
> class isn't inserted into rb-trees yet. Thus init_ed() and init_vf()
> must be called in place of update_ed() and update_vf().
> 
> Remove isn't required because for now curves cannot be disabled.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
