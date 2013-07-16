From: David Miller <davem@davemloft.net>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 13:58:57 -0700 (PDT)
Message-ID: <20130716.135857.1132486724952537431.davem@davemloft.net>
References: <20130716.125641.1190207010366517153.davem@davemloft.net>
	<1374007586.1949.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933954Ab3GPU7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:59:00 -0400
In-Reply-To: <1374007586.1949.25.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 16 Jul 2013 13:46:26 -0700

> On Tue, 2013-07-16 at 12:56 -0700, David Miller wrote:
>> 
>> I assume that the only reason sysfs_format_mac() exists at all, and
>> don't just use scnprintf() calls with "%pm\n", is that some devices
>> have MAC addresses which are not 6 bytes in length.
>> 
>> But it's such a waste to have this special case piece of code
>> just for that.
>> 
>> It would make so much more sense to allow specifying a length
>> specifier to %pm and friends.
> 
> scnprintf("%*ph", (int)size, buffer)

Yes, exactly, something like that.
