From: David Miller <davem@davemloft.net>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
 for adaptive dcache hash table sizing (resend)
Date: Tue, 07 Oct 2008 14:06:45 -0700 (PDT)
Message-ID: <20081007.140645.119998645.davem@davemloft.net>
References: <20081007070225.GB5959@wotan.suse.de>
	<20081007071827.GB5010@infradead.org>
	<20081007075309.GA16143@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org, paulmck@us.ibm.com
To: npiggin@suse.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756139AbYJGVHa@vger.kernel.org>
In-Reply-To: <20081007075309.GA16143@wotan.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nick Piggin <npiggin@suse.de>
Date: Tue, 7 Oct 2008 09:53:09 +0200

> Dcache lookup is partially a tree lookup, but also how do you look up
> entries in a given directory? That is not naturally a tree lookup. Could
> be a per directory tree, though, or a hash, or trie.
> 
> Anyway, I don't volunteer to change that just yet ;)

Historically speaking, the original dcache by Thomas Schoebel-Theuer
(circa 1997) was in fact implemented as a per-directory hash table.

This has all kinds of recursion and other issues, which is why Linus
eventually changed it to use a global hash table scheme.
