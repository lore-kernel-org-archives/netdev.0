From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/2] net/sched: fq_codel: Avoid set-but-unused
 variable
Date: Thu, 16 Mar 2017 13:10:29 +0300
Message-ID: <9d2c7335-2b0b-d199-9392-35ac50e0d430@cogentembedded.com>
References: <1489654145-20532-1-git-send-email-ogerlitz@mellanox.com>
 <1489654145-20532-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:32779 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdCPKms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 06:42:48 -0400
Received: by mail-lf0-f48.google.com with SMTP id a6so18315118lfa.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 03:42:47 -0700 (PDT)
In-Reply-To: <1489654145-20532-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 3/16/2017 11:49 AM, Or Gerlitz wrote:

> The code introduced by commit 2ccccf5fb "net_sched: update hierarchical
> backlog too" only sets prev_backlog in fq_codel_dequeue() but not

    Need 12 hex digits and () around "<summary>"; see 
Documentation/process/submitting-patches.rst.

> using that anywhere, remove that setting.
>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
[...]

MBR, Sergei
