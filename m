From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] mips: Update some more defconfigs which were
 missing CONFIG_NET.
Date: Wed, 24 Sep 2014 16:47:14 -0400 (EDT)
Message-ID: <20140924.164714.695249345899530955.davem@davemloft.net>
References: <20140924.144914.467369651395057588.davem@davemloft.net>
	<20140924204007.GC27927@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbaIXUrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:47:16 -0400
In-Reply-To: <20140924204007.GC27927@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 24 Sep 2014 13:40:07 -0700

> On Wed, Sep 24, 2014 at 02:49:14PM -0400, David Miller wrote:
>> 
>> Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
>> 'select'.")  removed what happened to be the only instance of 'select
>> NET'. Defconfigs that were relying on the select now lack networking
>> support.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  arch/mips/configs/nlm_xlp_defconfig | 1 +
>>  arch/mips/configs/nlm_xlr_defconfig | 1 +
> 
> My list of affected configurations is much larger.

Can you actually check my tree?

I noted in my introductory posting (you did read it right?) that
these changes are on top of the patches already done by Michal
Marek.
