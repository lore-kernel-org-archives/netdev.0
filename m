From: Xiubo Li <lixiubo@cmss.chinamobile.com>
Subject: Re: [PATCH] netfilter: fix possible ZERO_SIZE_PTRpointerdereferencing
 error.
Date: Thu, 02 Jun 2016 10:40:15 +0800
Message-ID: <574F9C8F.4070609@cmss.chinamobile.com>
References: <1464770068-7508-1-git-send-email-lixiubo@cmss.chinamobile.com> <20160601092711.GB2711@salvia> <574EB07B.3060307@cmss.chinamobile.com> <20160601110425.GA8276@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3388 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbcFBCkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 22:40:23 -0400
In-Reply-To: <20160601110425.GA8276@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/06/2016 19:04, Pablo Neira Ayuso wrote:
> On Wed, Jun 01, 2016 at 05:52:59PM +0800, Xiubo Li wrote:
>>>>   net/netfilter/x_tables.c | 3 +++
>>>>   1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
>>>> index c8a0b7d..4df8e38 100644
>>>> --- a/net/netfilter/x_tables.c
>>>> +++ b/net/netfilter/x_tables.c
>>>> @@ -1185,6 +1185,9 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)
>>>
>>> What kernel version are you using? I don't see xt_hook_link() in the
>>> development tree.
>>
>> Sorry, in the wrong tree, i just work on linux-next tree, forget to checkout
>> the newest tags.
>>
>> Should I will use nf.git tree or others instead ?
>
> Yes please, thanks.
>

Okay.

Thanks,

BRs
Xiubo Li
