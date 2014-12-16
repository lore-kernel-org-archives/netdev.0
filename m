From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY
 reset is blocked
Date: Tue, 16 Dec 2014 10:08:10 +0800
Message-ID: <548F940A.4050409@windriver.com>
References: <1418632754-16698-1-git-send-email-Yanjun.Zhu@windriver.com> <1418632754-16698-4-git-send-email-Yanjun.Zhu@windriver.com> <E66F6C44A7A6EA49ABFC80EA526506DF65A865A3@ALA-MBB.corp.ad.wrs.com> <20141215133335.GC28701@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Zhu Yanjun <zyjzyj2000@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ALLAN, BRUCE" <bruce.w.allan@intel.com>,
	"KIRSHER, JEFFREY" <jeffrey.t.kirsher@intel.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49922 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbaLPCIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 21:08:38 -0500
In-Reply-To: <20141215133335.GC28701@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Willy

Thanks for your reply.

I will fix it and send V2.

Best Regards!
Zhu Yanjun
On 12/15/2014 09:33 PM, Willy Tarreau wrote:
> On Mon, Dec 15, 2014 at 01:21:43PM +0000, Zhu, Yanjun wrote:
>> Hi, Willy
>>
>> Thanks for your reply.
>>
>> This patch "[PATCH 3/5] e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked" exists in tag v3.1.
>>
>> Please follow these steps, this patch can be found:
>>
>> 1. git checkout -f v3.1
>>
>> 2. git log -p drivers/net/e1000e/ich8lan.c
>>
>> 3. search "b7d6e335"
>>
>> Then we will find this patch.
> Ah it's because you truncated the commit ID from the right instead of from
> the left. Truncated commit IDs are valid from the left, not from the right.
> In your case, the commit is 6cc7aaed70c96c3933fbacbad582fc79b7d6e335
> ("e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked"), so
> the truncated ID is 6cc7aae, not b7d6e335. It's important to fix that in
> your commit messages so that a "git show" works correctly (it failed for me
> for this precise reason).
>
> Thanks,
> Willy
>
