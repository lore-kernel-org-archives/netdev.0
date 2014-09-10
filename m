From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: enable GRO for IPIP and SIT
Date: Tue, 09 Sep 2014 21:32:05 -0700 (PDT)
Message-ID: <20140909.213205.2150566517395290798.davem@davemloft.net>
References: <1410286996-302-1-git-send-email-therbert@google.com>
	<20140909.202738.854167452821989542.davem@davemloft.net>
	<CA+mtBx_1VWkzU3EcyR=o45CWGevhGdiJiKH-z5Kc7qzqyNkC9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaIJEcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 00:32:08 -0400
In-Reply-To: <CA+mtBx_1VWkzU3EcyR=o45CWGevhGdiJiKH-z5Kc7qzqyNkC9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 9 Sep 2014 21:04:27 -0700

> On Tue, Sep 9, 2014 at 8:27 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue,  9 Sep 2014 11:23:13 -0700
>>
>>> This patch sets populates the IPIP and SIT offload structures with
>>> gro_receive and gro_complete functions. This enables use of GRO
>>> for these. Also, fixed a problem in IPv6 where we were not properly
>>> initializing flush_id.
>>
>> We're going to need to sort this out, because these functions are
>> now static after Eric's patches to fix sparse warnings.
>>
>> You're going to have to respin this with that patch you intended
>> to add from the previous series that exported these routines.
> 
> I might be missing something, but I believe the functions referred in
> this patch series were already static.

Oops my bad, let me rereview this...

Yep it's fine, applied, thanks!
