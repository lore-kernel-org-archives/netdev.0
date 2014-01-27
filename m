From: Wang Weidong <weidong1991.wang@gmail.com>
Subject: Re: [PATCH net-next] 8139cp: remove a won't occurred BUG_ON
Date: Mon, 27 Jan 2014 20:57:37 +0800
Message-ID: <52E657C1.3000002@gmail.com>
References: <52E4C862.9050103@huawei.com>	 <1390778623.2735.69.camel@deadeye.wl.decadent.org.uk>	 <52E5B309.1080402@huawei.com> <1390823686.2735.138.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>,
	Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40256 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaA0M5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 07:57:33 -0500
Received: by mail-pd0-f173.google.com with SMTP id y10so5679720pdj.32
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 04:57:32 -0800 (PST)
In-Reply-To: <1390823686.2735.138.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>

On 2014/1/27 19:54, Ben Hutchings wrote:
> On Mon, 2014-01-27 at 09:14 +0800, Wang Weidong wrote:
>> On 2014/1/27 7:23, Ben Hutchings wrote:
>>> On Sun, 2014-01-26 at 16:33 +0800, Wang Weidong wrote:
>>>> when variable i go to the BUG_ON the value is equal to the CP_NUM_STATS,
>>>> so the BUG_ON won't occur, so remove it
>>>
>>> We hope that every BUG_ON() does not occur, but that doesn't mean they
>>> should be removed.  This check is meant to catch mistakes when adding
>>> new statistics.
>>>
>>> Ben.
>>>
>> Hi, Ben.
>>
>> Yeah, but I think If someone would add new statistics, he should take into account
>> it instead the BUG_ON helper.
>>
>> And that, I found some other drivers' get_ethtool_stats no have BUG_ON. Should we
>> add the BUG_ON into them?
> [...]
>
> The important thing is that the get_stats, get_sset_count and
> get_strings operations are consistent.  Depending on how they are
> implemented, a BUG_ON or BUILD_BUG_ON may be useful to check that.  I
> don't think there's any universal best practice.
>
> Ben.
>
Ok, Got it.
Thanks for your answers.

Regards,
Wang
