From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 10324] New: kernel panic ip_route_input
Date: Tue, 25 Mar 2008 16:45:49 -0700 (PDT)
Message-ID: <20080325.164549.141096069.davem@davemloft.net>
References: <bug-10324-10286@http.bugzilla.kernel.org/>
	<20080325130302.d3f6757c.akpm@linux-foundation.org>
	<20080325230945.M27660@nuclearcat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, rjw@sisk.pl
To: nuclearcat@nuclearcat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752738AbYCYXpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:45:54 -0400
In-Reply-To: <20080325230945.M27660@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denys" <nuclearcat@nuclearcat.com>
Date: Wed, 26 Mar 2008 01:12:01 +0200

> Changing from FIB_TRIE to FIB_HASH, and it is not panicing anymore. It seems
> recent patches to FIB_TRIE broke something (i have complicated setup with ifb,
> maybe it will help). If you can point me to any patch, i can reverse it and
> try again with TRIE.

Unfortunately there were 39 changes made to fib_trie
during this time.  So it's not like we can give you
one patch to try reverting :-/

Really, the fastest way to track this down would be
to do a bisect, focused in on net/ipv4/fib_trie.c
which git bisect does allow you to do.
