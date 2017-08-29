From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] sch_hhf: fix null pointer dereference on init failure
Date: Tue, 29 Aug 2017 22:46:40 +0300
Message-ID: <b89785c3-d97d-3153-72ea-c0c22160d655@cumulusnetworks.com>
References: <1504033335-19098-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36800 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751664AbdH2Tqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:46:43 -0400
Received: by mail-wm0-f48.google.com with SMTP id u126so2630233wmg.1
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 12:46:42 -0700 (PDT)
In-Reply-To: <1504033335-19098-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/08/17 22:02, Nikolay Aleksandrov wrote:
> If sch_hhf fails in its ->init() function (either due to wrong
> user-space arguments as below or memory alloc failure of hh_flows) it
> will do a null pointer deref of q->hh_flows in its ->destroy() function.
> 
> To reproduce the crash:
> $ tc qdisc add dev eth0 root hhf quantum 2000000 non_hh_weight 10000000
> 

Uh, sorry about sending these out separately. I'll send the rest as a set for
easier review once I test them, should be just a couple more.
