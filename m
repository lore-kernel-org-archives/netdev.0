From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 00/17] fib_trie: Reduce time spent in
 fib_table_lookup by 35 to 75%
Date: Mon, 22 Dec 2014 13:53:28 -0500 (EST)
Message-ID: <20141222.135328.352598984893793430.davem@davemloft.net>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531AbaLVSxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:53:31 -0500
In-Reply-To: <CAA93jw7Zz8_wToKOou42mXhgunZypQ6f=oGEHZk2K6CbrsrNqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@gmail.com>
Date: Mon, 22 Dec 2014 10:08:09 -0800

> impressive. I think. But I don't quite understand what you mean by a depth of 7?

He means the deepest path in the fib_trie datastructure that is
holding the routing table.
