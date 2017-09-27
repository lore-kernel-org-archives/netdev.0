From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: Update sk_for_each_entry_offset_rcu macro to
 utilize rcu methods hlist_next_rcu. This fixes the warnings thrown by
 sparse regarding net/ipv4/udp.c on line 1974.
Date: Tue, 26 Sep 2017 20:03:39 -0700 (PDT)
Message-ID: <20170926.200339.2029420994787006076.davem@davemloft.net>
References: <20170927005406.5935-1-devtimhansen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927005406.5935-1-devtimhansen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Tue, 26 Sep 2017 20:54:05 -0400

> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

This is a poor patch submission on many levels.

But the main problem, is that there is no use of
sk_for_each_entry_offset_rcu() in any of my networking kernel trees.

Referencing code by line number never works, you have to mention
what version of the kernel, what tree, and where in what fucntion
the problem is occurring.

Secondly, sk_for_each_entry_offset_rcu() is not meant to be used
in _raw() contexts.  This is why it's not called
sk_for_each_entry_offset_rcu_raw().

The sparse warning is probably legitimate, and points to a bug.

But nobody can tell where becuase you haven't told us what tree
and where this happens.
