From: David Miller <davem@davemloft.net>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Sat, 01 Nov 2014 13:41:42 -0400 (EDT)
Message-ID: <20141101.134142.888127846627939710.davem@davemloft.net>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>
	<1414805353.16849.98.camel@decadent.org.uk>
	<CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, vlee@twopensource.com, amirv@mellanox.com,
	ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	eugenia@mellanox.com, matanb@mellanox.com, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbaKARlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 13:41:44 -0400
In-Reply-To: <CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Sat, 1 Nov 2014 10:17:43 -0700

> On Fri, Oct 31, 2014 at 6:29 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
>> On Sat, 2014-10-18 at 14:14 -0700, Vinson Lee wrote:
>>> Hi.
>>>
>>> Please consider backporting upstream commit
>>> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
>>> race" to stable kernels <= 3.11.
>>>
>>> commit 2d4b646613d6b12175b017aca18113945af1faf3
>>> Author: Eugenia Emantayev <eugenia@mellanox.com>
>>> Date:   Thu Jul 25 19:21:23 2013 +0300
>>>
>>>     net/mlx4_en: Fix BlueFlame race
>> [...]
>>
>> David doesn't support anything older than 3.12 now, so you should send
>> requests for older stable branches directly to the stable list.
> 
> Interesting, is there a document saying which stable kernels netdev
> supports? and how are they chosen?
> 
> I thought netdev supports all -stable maintainers support.
> 
> Anyway, we will send the request directly to Greg then.

There is no documented way nor do I wish to state anything so strictly.
I want maximum flexibility for such a time consuming task.

I tend to go back 3 or 4 releases at most, and it really depends upon
the difficulty of the backports and my own time constraints.
