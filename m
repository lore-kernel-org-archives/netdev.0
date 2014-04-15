From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net 1/3] net: move LOOPBACK_IFINDEX to
 include/net/flow.h
Date: Tue, 15 Apr 2014 15:06:00 -0400 (EDT)
Message-ID: <20140415.150600.1198094454060493410.davem@davemloft.net>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, ja@ssi.bg,
	cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaDOTGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 15:06:02 -0400
In-Reply-To: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cong, first of all, I'd like you to combine patches #1 and #2.

Also, Julian made it clear that several other changes needed happen
besides the single fib_validate_source() call site you are modifying
in patch #3.

He also said, for example, that the flow4_iif assignment in
__fib_validate_source() needs adjusting as well.

He furthermore said that other assignments of zero to flow4_iif
in netfilter and elsewhere must be adjusted as well.

Please also provide a proper 0/N patch posting next time explaining
exactly what the series does and why it is necessary.
