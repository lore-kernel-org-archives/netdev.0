From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid
 miuse
Date: Tue, 22 Jan 2013 23:13:53 -0500 (EST)
Message-ID: <20130122.231353.2100388787067184936.davem@davemloft.net>
References: <50FF2F18.1050408@jp.fujitsu.com>
	<20130122.205346.633138554393148358.davem@davemloft.net>
	<F6CB40852BC6EF489E0AA83EFF537F470876B9FD@G01JPEXMBYT04>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sanagi.koki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab3AWEN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:13:58 -0500
In-Reply-To: <F6CB40852BC6EF489E0AA83EFF537F470876B9FD@G01JPEXMBYT04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sanagi, Koki" <sanagi.koki@jp.fujitsu.com>
Date: Wed, 23 Jan 2013 02:32:52 +0000

>> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> Date: Wed, 23 Jan 2013 09:30:16 +0900
>> 
>> > Due to its name and appearance, someone thinks this only checks if
>> > ip_summed is CHECKSUM_UNNECESARRY.  But actually, this returns true
>> > even if ip_summed is CHECKSUM_PARTIAL.  To avoid misuse, this patch a
>> > comment which specifies that CHECKSUM_PARTIAL is OK.
>> >
>> > Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>> 
>> I'm not applying this, sorry.  It's a one line function and it's not so
>> non-obvious that it deserves an 8 line comment.
> 
> OK.  I just felt weird that CHECKSUM_* is not bit flag but this function handles
> it as if it was bit flag.

The function name says what it does, it determines whether a checksum
is necessary or not.  How that is implemented is another issue.
