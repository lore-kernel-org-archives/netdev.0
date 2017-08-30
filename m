From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] sch_hhf: fix null pointer dereference on init failure
Date: Tue, 29 Aug 2017 18:24:44 -0700
Message-ID: <CAM_iQpWN6bubnnFfqoZeiuH5NF3tpQ7nb91CBp09Yw-NJzRcng@mail.gmail.com>
References: <1504033335-19098-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:32854 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdH3BZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 21:25:05 -0400
Received: by mail-pf0-f174.google.com with SMTP id r62so15031120pfj.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 18:25:05 -0700 (PDT)
In-Reply-To: <1504033335-19098-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 12:02 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> First I did it with the check in the for () conditional, but this is more
> visible and explicit. Let me know if you'd like the shorter version. :-)

Or, if you want to make the patch size smaller, just check NULL
before for():

if (!q->hh_flows)
    return;

for (...)

Up to you, I have no strong opinion here, slightly prefer a smaller
one for backport.
