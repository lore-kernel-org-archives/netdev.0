From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Wed, 14 Oct 2015 18:58:12 +0800
Message-ID: <CAJFZqHyS2Ain250=6Xn0eYy3UmKySg1VvodqhS3vM3eXXvKR0g@mail.gmail.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
	<561E1DE8.6070400@huawei.com>
	<CAJFZqHz=PjafQNmifksDPigfiUki1AF00Zj0Q6W-6t-o6gL1dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Sheng Yong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:34011 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbbJNK6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 06:58:13 -0400
Received: by qgez77 with SMTP id z77so38833211qge.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 03:58:12 -0700 (PDT)
In-Reply-To: <CAJFZqHz=PjafQNmifksDPigfiUki1AF00Zj0Q6W-6t-o6gL1dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:53 PM, Li RongQing <roy.qing.li@gmail.com> wrote:
> On Wed, Oct 14, 2015 at 5:18 PM, Sheng Yong <shengyong1@huawei.com> wrote:
>> Hi, Rongqing,
>>
>> Cced Martin KaFai Lau <kafai@fb.com>
>>
>> It seems you trigger the problem that I met before, here is the link of disucssion:
>> http://www.spinics.net/lists/netdev/msg314717.html
>>
>> You can try these patches to check if they resolve your problem:
>> 7035870d1219 | 2015-05-03 | ipv6: Check RTF_LOCAL on rt->rt6i_flags instead of rt->dst.flags
>> 653437d02f1f | 2015-04-28 | ipv6: Stop /128 route from disappearing after pmtu update
>>
>> thanks,
>> Sheng
>>


You are right, these two commits fixed my issue

Thanks

-Roy
