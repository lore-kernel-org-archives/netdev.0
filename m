From: Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH] irda: Fix likely typo in output format string
Date: Wed, 31 Aug 2016 17:36:44 -0400
Message-ID: <857C547F-D381-44F4-A5E5-C8B390B931F3@linuxhacker.ru>
References: <1472267646-810675-1-git-send-email-green@linuxhacker.ru> <20160831.143151.313012072430161185.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831.143151.313012072430161185.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 31, 2016, at 5:31 PM, David Miller wrote:

> From: Oleg Drokin <green@linuxhacker.ru>
> Date: Fri, 26 Aug 2016 23:14:06 -0400
> 
>> %ul would print an unsigned with a letter l at the end which does
>> not seem to be desired here, on the other hand the value being printed
>> is u32 so just drop the l instead of converting to %lu
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> 
> %u is for unsigned values, and these are "s32" thus signed.

Hm, you are right.
I could swear I saw them as unsigned when I looked at it.

Anyway can they really be negative? they are seconds and usec,
should I change them to u32 too?
