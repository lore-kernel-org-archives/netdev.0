From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] parisc: Update defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 16:46:40 -0400 (EDT)
Message-ID: <20140924.164640.83507277835762501.davem@davemloft.net>
References: <20140924.144929.1831753286382773236.davem@davemloft.net>
	<20140924203909.GB27927@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747AbaIXUqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:46:42 -0400
In-Reply-To: <20140924203909.GB27927@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 24 Sep 2014 13:39:09 -0700

> On Wed, Sep 24, 2014 at 02:49:29PM -0400, David Miller wrote:
>> 
>> Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
>> 'select'.")  removed what happened to be the only instance of 'select
>> NET'. Defconfigs that were relying on the select now lack networking
>> support.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  arch/parisc/configs/a500_defconfig | 1 +
> 
> My list also includes c8000_defconfig.

It has NET=y in my tree.

Via:

commit 25fee47f9ccd834bfb95c6f95e07033b0f2d5ddf
Author: Michal Marek <mmarek@suse.cz>
Date:   Tue Sep 23 17:44:01 2014 +0200

    parisc: Set CONFIG_NET=y in defconfigs
