From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Tue, 18 Oct 2016 18:18:40 -0400
Message-ID: <e3ad33a8-f254-25f9-df96-2df325bd366b@mojatatu.com>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net>
 <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com>
 <58069B3B.20009@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35038 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932719AbcJRWSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 18:18:42 -0400
Received: by mail-it0-f65.google.com with SMTP id 139so628898itm.2
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 15:18:42 -0700 (PDT)
In-Reply-To: <58069B3B.20009@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-18 05:59 PM, Daniel Borkmann wrote:

> Ahh sure, looks good to me. All other RTM_DELTFILTER events
> would be for the entire tcf_proto and 'enforced' destroy, so
> zero handle would indicate that then as opposed to a individual
> cls delete with non-zero handle. Seems fine.

Ok, thanks. I will send an official patch when i get a chance.
I tested earlier on net-next; but maybe this deserves to go
on net.

cheers,
jamal
