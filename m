From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/7] seq_printf cleanups
Date: Tue, 28 Oct 2014 08:51:39 -0700
Message-ID: <1414511499.6643.11.camel@perches.com>
References: <20140929124246.3e39dac8@gandalf.local.home>
	 <cover.1412031505.git.joe@perches.com>
	 <20141028113240.74dbe5c5@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Petr Mladek <pmladek@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mtd@lists.infradead.org, netdev@vger.kernel.org,
	cluster-devel@redhat.com, linux-fsdevel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20141028113240.74dbe5c5@gandalf.local.home>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-28 at 11:32 -0400, Steven Rostedt wrote:
> If you haven't already done so, can you update checkpatch.pl to
> complain if someone checks the return value of seq_printf(),
> seq_puts(), or seq_putc().

I'm not sure that matters much as a rule because I
hope soon the compiler will bleat when that happens.

There are several more too:

	seq_vprintf
	seq_escape
	seq_write
	seq_bitmap
	seq_cpumask/seq_nodemask (and _list variants),
	seq_put_decimal_xxx



