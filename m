From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix rt6_update_expires
Date: Tue, 17 Apr 2012 22:32:33 -0400 (EDT)
Message-ID: <20120417.223233.351461241401990679.davem@davemloft.net>
References: <20120413.125851.894792528374368454.davem@davemloft.net>
	<20120416133439.GB18159@midget.suse.cz>
	<4F8E25F0.3040703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523Ab2DRCd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:33:28 -0400
In-Reply-To: <4F8E25F0.3040703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Wed, 18 Apr 2012 10:24:48 +0800

> 于 2012年04月16日 21:34, Jiri Bohac 写道:
>> 
>> Commit 1716a961 (ipv6: fix problem with expired dst cache) broke PMTU
>> discovery. rt6_update_expires() calls dst_set_expires(), which only updates
>> dst->expires if it has not been set previously (expires == 0) or if the new
>> expires is earlier than the current dst->expires.
>> 
>> rt6_update_expires() needs to zero rt->dst.expires, otherwise it will contain
>> ivalid data left over from rt->dst.from and will confuse dst_set_expires().
>> 
>> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
 ...
> looks good to me, thanks.

Applied.
