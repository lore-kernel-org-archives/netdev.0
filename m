From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Tue, 18 Oct 2016 23:59:23 +0200
Message-ID: <58069B3B.20009@iogearbox.net>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net> <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39797 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754039AbcJRV72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 17:59:28 -0400
In-Reply-To: <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2016 11:21 PM, Jamal Hadi Salim wrote:
[...]
> I was sitting on this patch I was going to send ;->
> Does this resolve it?

Ahh sure, looks good to me. All other RTM_DELTFILTER events
would be for the entire tcf_proto and 'enforced' destroy, so
zero handle would indicate that then as opposed to a individual
cls delete with non-zero handle. Seems fine.
