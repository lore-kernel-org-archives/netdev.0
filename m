From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v3 2/2] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Thu, 8 Jun 2017 15:33:58 +0800
Message-ID: <6CE04FE7-4904-4047-95F5-80461324CDA6@cmss.chinamobile.com>
References: <1496896364-27153-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496896364-27153-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170608043847.uejvydlitzuik76j@ast-mbp>
 <3A078CA0-C9C8-45D2-A359-1FB38B25792D@cmss.chinamobile.com>
 <20170608050041.cte3gpavshg2nmdc@ast-mbp>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "=David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:18386 "EHLO
        cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdFHHeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 03:34:02 -0400
In-Reply-To: <20170608050041.cte3gpavshg2nmdc@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 8 Jun 2017, at 1:00 PM, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> On Thu, Jun 08, 2017 at 12:56:58PM +0800, 严海双 wrote:
>> 
>>> On 8 Jun 2017, at 12:38 PM, Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
>>> 
>>> On Thu, Jun 08, 2017 at 12:32:44PM +0800, Haishuang Yan wrote:
>>>> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
>>>> dst_release to free it in error code path.
>>>> 
>>>> CC: Alexei Starovoitov <ast@fb.com>
>>>> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
>>>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>>> 
>>> I don't get it. Why did you send another version of the patch?
>>> What was wrong with previous approach that myself and Eric acked?
>>> 
>>> 
>> 
>> Sorry for your confusing, because Pravin Shelar give a feedback in ipv4 patch, see below:
> 
> hmm. right.
> Then it raises the question: How did you test this and previous patch?
> 
> since previous version was sort-of fixing the bug, but completely
> breaking the logic...
> 
> 

Sorry for my previous fault, I tried to fix this problem in theory without testing carefully.
I have tested the latest patches, it works ok now.
