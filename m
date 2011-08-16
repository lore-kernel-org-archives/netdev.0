From: David Miller <davem@davemloft.net>
Subject: Re: get_random_int() should use hash[1]
Date: Tue, 16 Aug 2011 02:10:31 -0700 (PDT)
Message-ID: <20110816.021031.1778295949152117484.davem@davemloft.net>
References: <20110816090723.18492.qmail@science.horizon.com>
	<20110816.020935.717525957035990843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab1HPJKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 05:10:35 -0400
In-Reply-To: <20110816.020935.717525957035990843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 16 Aug 2011 02:09:35 -0700 (PDT)

> From: "George Spelvin" <linux@horizon.com>
> Date: 16 Aug 2011 05:07:23 -0400
> 
>> Re: commit e997d47bff5a467262ef224b4cf8cbba2d3eceea
>> 
>> As long as you're using MD5, you should know that each round only
>> modifies one word of the state.  The order is [0], [3], [2], [1],
>> repeating 64 times.  Thus, on output, word [1] is the "most hashed"
>> word.  If you really wanted word [0], you could just skip the last
>> 3 rounds.
>> 
>> It's not really critical, but as long as you're performing the
>> rounds, you might as well use them...
> 
> Please provide a proper signoff with your change and properly
> "-p1" base your patch.
> 
> Thanks.

Also this change is of interest to, and effects, folks outside of
networking.  So probably want to CC: linux-kernel when you respin
this.
