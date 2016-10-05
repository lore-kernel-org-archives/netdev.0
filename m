From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: pull-request: wireless-drivers-next 2016-09-29
Date: Wed, 05 Oct 2016 07:50:39 +0300
Message-ID: <87bmyzpffk.fsf@kamboji.qca.qualcomm.com>
References: <87ponmve2v.fsf@kamboji.qca.qualcomm.com>
        <20160930.013245.1474369794552343595.davem@davemloft.net>
        <f7t4m4xtszj.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f7t4m4xtszj.fsf@redhat.com> (Aaron Conole's message of "Fri, 30
        Sep 2016 09:30:40 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron Conole <aconole@redhat.com> writes:

> David Miller <davem@davemloft.net> writes:
>
>> From: Kalle Valo <kvalo@codeaurora.org>
>> Date: Thu, 29 Sep 2016 19:57:28 +0300
>>
> ...
>>> Or actually I had one problem. While doing a test merge I noticed that
>>> net-next fails to compile for me, but I don't think this is anything
>>> wireless related:
>>> 
>>>   CC      net/netfilter/core.o
>>> net/netfilter/core.c: In function 'nf_set_hooks_head':
>>> net/netfilter/core.c:96:149: error: 'struct net_device' has no
>>> member named 'nf_hooks_ingress'
>>
>> Yes, I am aware of this build issue and will tackle it myself if someone
>> doesn't beat me to it.
>
> Sorry, I introduced this.  I posted a series targetted at nf-next to
> solve this, but it could be merged to net-next instead, if that makes
> sense.
>
> The patches are here:
>
> https://patchwork.ozlabs.org/patch/676287/
> https://patchwork.ozlabs.org/patch/676288/

net-next still fails to compile for me. I verified that these two
patches fix it but I don't see them in net-next yet.

-- 
Kalle Valo
