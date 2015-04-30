From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Wed, 29 Apr 2015 22:35:21 -0400
Message-ID: <554194E9.5040002@mojatatu.com>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <20150430003740.GF7025@acer.localdomain> <55417F80.4000506@iogearbox.net> <20150430014316.GB7956@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430014316.GB7956@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/15 21:43, Patrick McHardy wrote:
> On 30.04, Daniel Borkmann wrote:
>> On 04/30/2015 02:37 AM, Patrick McHardy wrote:
>>> On 30.04, Pablo Neira Ayuso wrote:

>> Totally agree with you that the situation is quite a mess. From tc ingress/
>> egress side, at least my use case is to have an as minimal as possible entry
>> point for cls_bpf/act_bpf, which is what we were working on recently. That
>> is rather ``fresh'' compared to the remaining history of cls/act in tc.
>
> It's more than a mess. Leaving aside the fully broken code at ingress,
> just look at the TC action APIs. Its "a failed state".

Since youve repeated about 100 that tc api being broken, maybe
you can explain more rationally? By that i mean dont use words
like words like "crap" or "failed state" or no chest-thumping.
Lets say we totally stopped trying to reuse netfilter code, what are
you talking about?

I think there is confusion about usability vs merits of performance.

cheers,
jamal

