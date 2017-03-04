From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: net/sched: act_skbmod: rcu_read_unlock in tcf_skbmod_dump?
Date: Sat,  4 Mar 2017 23:49:39 +0300
Message-ID: <1488660579-3056-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:43396 "EHLO mail.ispras.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752103AbdCDUtw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Mar 2017 15:49:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

rcu_read_unlock() in tcf_skbmod_dump() looks suspicious to me.
What does it mean there?
