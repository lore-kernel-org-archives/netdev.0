From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 0/7] seq_printf cleanups
Date: Tue, 28 Oct 2014 11:32:40 -0400
Message-ID: <20141028113240.74dbe5c5@gandalf.local.home>
References: <20140929124246.3e39dac8@gandalf.local.home>
	<cover.1412031505.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Petr Mladek <pmladek@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mtd@lists.infradead.org, netdev@vger.kernel.org,
	cluster-devel@redhat.com, linux-fsdevel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1412031505.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe,

If you haven't already done so, can you update checkpatch.pl to
complain if someone checks the return value of seq_printf(),
seq_puts(), or seq_putc().

It should state that those functions will soon be returning void.

Thanks!

-- Steve
