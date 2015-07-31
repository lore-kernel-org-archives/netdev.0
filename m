From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] act_mirred: avoid calling tcf_hash_release() when
 binding
Date: Sat, 01 Aug 2015 00:33:39 +0200
Message-ID: <55BBF7C3.8010605@iogearbox.net>
References: <1438301541-26192-1-git-send-email-xiyou.wangcong@gmail.com>	<55BB48B8.6060201@iogearbox.net> <CAM_iQpWmHizNaO7_DhV97APYFpZoApZO3ZzAHu8kv6MopuAg4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49513 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbbGaWdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:33:41 -0400
In-Reply-To: <CAM_iQpWmHizNaO7_DhV97APYFpZoApZO3ZzAHu8kv6MopuAg4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2015 12:25 AM, Cong Wang wrote:
> On Fri, Jul 31, 2015 at 3:06 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Did you test all variants on this?
>>
>> I.e. what happens when you replace an existing one, I think the
>> refcnt should also be dropped here. It looks like we only drop
>> it, in case we tried to add an action to an already existing index ...
>
> Yeah, clearly the replace case is anti-pattern too, like you showed.
>
> But that is a different bug, right? Since 'bind' is independent of
> 'replace'. As in $subject, my patch only fixes the binding case.
> I will send a following patch to fix replace case.

I wasn't aware you planned to send an extra patch for the other issue,
probably not worth the split, but I don't mind.

Thanks,
Daniel
