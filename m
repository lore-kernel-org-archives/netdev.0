From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Wed, 18 Dec 2013 09:58:01 +0800
Message-ID: <CAJFZqHywaN4k64zd-fcw7=DD+6iNX_Psuwi2QKH_GX-_04TVSg@mail.gmail.com>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com>
	<52AFC43C.9080804@cn.fujitsu.com>
	<CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com>
	<52AFE7E3.3070806@cn.fujitsu.com>
	<CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com>
	<20131217070231.GA11970@order.stressinduktion.org>
	<52B00150.3070002@cn.fujitsu.com>
	<20131217134823.GC18396@order.stressinduktion.org>
	<52B0F0C4.1010803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:47080 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab3LRB6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 20:58:03 -0500
Received: by mail-ve0-f171.google.com with SMTP id pa12so4870893veb.16
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 17:58:01 -0800 (PST)
In-Reply-To: <52B0F0C4.1010803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 8:48 AM, Gao feng <gaofeng@cn.fujitsu.com> wrote:
> On 12/17/2013 09:48 PM, Hannes Frederic Sowa wrote:
>> On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
>>> The from of new cloned rt should not be set if it's impossible for the ort
>>> to be expired.
>>
>> Actually, why do you think so? What could go wrong?
>>
>
> I just don't want rt6_check_expired to check some impossible expired routes.
>

What is wrong if we set from for new cloned rt by checking if ort has
RTF_EXPIRES flag?

-Roy
