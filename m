From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] fou: avoid using sk_user_data before it is
 initialised
Date: Tue, 24 May 2016 16:23:33 -0700 (PDT)
Message-ID: <20160524.162333.1199998379578497620.davem@davemloft.net>
References: <1463723837-9098-1-git-send-email-simon.horman@netronome.com>
	<20160523.135951.575984351254086980.davem@davemloft.net>
	<CAM_iQpXeoX_e2wi_gOMW_2VKMzAkEJ-J37tLZfsaDGwmiut7QA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon.horman@netronome.com, netdev@vger.kernel.org,
	tom@herbertland.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbcEXXXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 19:23:37 -0400
In-Reply-To: <CAM_iQpXeoX_e2wi_gOMW_2VKMzAkEJ-J37tLZfsaDGwmiut7QA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 May 2016 14:05:17 -0700

> On Mon, May 23, 2016 at 1:59 PM, David Miller <davem@davemloft.net> wrote:
>> From: Simon Horman <simon.horman@netronome.com>
>> Date: Fri, 20 May 2016 14:57:17 +0900
>>
>>> During initialisation sk->sk_user_data should not be used before
>>> it is initialised.
>>>
>>> Found by bisection after noticing the following:
>>  ...
>>> Fixes: d92283e338f6 ("fou: change to use UDP socket GRO")
>>> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>> ---
>>> v2
>>> * Updated implementation to simply access fou->protocol directly
>>>   as suggested by Tom Herbert and Cong Want
>>
>> I think this was resolved in another way meanwhile.  If a fix is still
>> needed, please respin.
> 
> This fix is only needed for -stable to backport, because Tom's
> fix is within a series of patches, which makes it hard to backport.

Ok, queued up for -stable.
