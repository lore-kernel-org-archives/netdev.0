From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 17:00:37 -0700
Message-ID: <1473724837.18970.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
         <1473723645.18970.109.camel@edumazet-glaptop3.roam.corp.google.com>
         <99274ae5-4f40-fc08-3d35-9b2fe7f792b5@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36796 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbcIMAAp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 20:00:45 -0400
Received: by mail-pa0-f66.google.com with SMTP id p2so2174017pap.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 17:00:45 -0700 (PDT)
In-Reply-To: <99274ae5-4f40-fc08-3d35-9b2fe7f792b5@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 19:56 -0400, Jamal Hadi Salim wrote:

> 
> Yes, I did ;->
> Another version coming. Is there a good way to catch
> something like this (ala userspace valgrind)?

You might try CONFIG_DEBUG_KMEMLEAK=y,
or simply run your script deleting/inserting the action one million
time ;)
