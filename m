From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] sched, cls: don't dump kernel addr into tc monitors
 on delete event
Date: Wed, 19 Oct 2016 00:21:58 +0200
Message-ID: <5806A086.2060401@iogearbox.net>
References: <f7e28cd6ec298a90dc33fcc85e7361eb92025690.1476821268.git.daniel@iogearbox.net> <c02ce4f1-ba99-f54c-d35d-ca81cc771c8a@mojatatu.com> <58069B3B.20009@iogearbox.net> <e3ad33a8-f254-25f9-df96-2df325bd366b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41094 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932719AbcJRWWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 18:22:02 -0400
In-Reply-To: <e3ad33a8-f254-25f9-df96-2df325bd366b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2016 12:18 AM, Jamal Hadi Salim wrote:
> On 16-10-18 05:59 PM, Daniel Borkmann wrote:
[...]
>> Ahh sure, looks good to me. All other RTM_DELTFILTER events
>> would be for the entire tcf_proto and 'enforced' destroy, so
>> zero handle would indicate that then as opposed to a individual
>> cls delete with non-zero handle. Seems fine.
>
> Ok, thanks. I will send an official patch when i get a chance.
> I tested earlier on net-next; but maybe this deserves to go
> on net.

net would be appropriate as mentioned in commit message.

Thanks,
Daniel
