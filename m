From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Fri, 9 Jun 2017 08:23:10 +0800
Message-ID: <854D089B-1932-45B0-8501-9C374FCA3F3B@cmss.chinamobile.com>
References: <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
 <20170608050041.cte3gpavshg2nmdc@ast-mbp>
 <6CE04FE7-4904-4047-95F5-80461324CDA6@cmss.chinamobile.com>
 <20170608.095958.853026498068086014.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:19265 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdFIAXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 20:23:17 -0400
In-Reply-To: <20170608.095958.853026498068086014.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 8 Jun 2017, at 9:59 PM, David Miller <davem@davemloft.net> wrote:
> 
> From: 严海双 <yanhaishuang@cmss.chinamobile.com>
> Date: Thu, 8 Jun 2017 15:33:58 +0800
> 
>>> On 8 Jun 2017, at 1:00 PM, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>> 
>>> On Thu, Jun 08, 2017 at 12:56:58PM +0800, 严海双 wrote:
>>>> 
>>>>> On 8 Jun 2017, at 12:38 PM, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>>>> 
>>>>> On Thu, Jun 08, 2017 at 12:32:44PM +0800, Haishuang Yan wrote:
>>>>>> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
>>>>>> dst_release to free it in error code path.
>>>>>> 
>>>>>> CC: Alexei Starovoitov <ast@fb.com>
>>>>>> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
>>>>>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>>>> 
>>>>> I don't get it. Why did you send another version of the patch?
>>>>> What was wrong with previous approach that myself and Eric acked?
>>>>> 
>>>>> 
>>>> 
>>>> Sorry for your confusing, because Pravin Shelar give a feedback in ipv4 patch, see below:
>>> 
>>> hmm. right.
>>> Then it raises the question: How did you test this and previous patch?
>>> 
>>> since previous version was sort-of fixing the bug, but completely
>>> breaking the logic...
>>> 
>>> 
>> 
>> Sorry for my previous fault, I tried to fix this problem in theory without testing carefully.
>> I have tested the latest patches, it works ok now.
> 
> This does not instill a lot of confidence in us.
> 
> I want someone else to test these patches, then you can resubmit them
> with proper Tested-by: tags added, since you thought it was OK to submit
> a patch without testing in the first place.

Ok, thanks.
