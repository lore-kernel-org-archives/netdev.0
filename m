From: David Miller <davem@davemloft.net>
Subject: Re: Does the ordering of the fib_table_dump or /proc/net/fib_trie
 matter?
Date: Tue, 06 Jan 2015 16:58:22 -0500 (EST)
Message-ID: <20150106.165822.1294578064447416624.davem@davemloft.net>
References: <54AC45CE.80800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbbAFV60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:58:26 -0500
In-Reply-To: <54AC45CE.80800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 06 Jan 2015 12:30:06 -0800

> The question I have is if that would screw up any user-space apps.  I
> know ip route can dump the list via "ip route show".  I'm just wondering
> if there would be any problem with default being the last entry instead
> of the first entry?

The ordering already changed once when we went from fib_hash to
fib_trie, nobody should depend upon the ordering.
