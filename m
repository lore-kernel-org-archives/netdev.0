From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 5/7] fs: Convert show_fdinfo functions to void
Date: Tue, 28 Oct 2014 10:43:12 -0400
Message-ID: <20141028104312.28168609@gandalf.local.home>
References: <20140929124246.3e39dac8@gandalf.local.home>
	<cover.1412031505.git.joe@perches.com>
	<e37e6e7b76acbdcc3bb4ab2a57c8f8ca1ae11b9a.1412031505.git.joe@perches.com>
	<20141028101158.3dde9880@gandalf.local.home>
	<1414506692.6643.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Petr Mladek <pmladek@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jeff Layton <jlayton@poochiereds.net>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1414506692.6643.2.camel@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Oct 2014 07:31:32 -0700
Joe Perches <joe@perches.com> wrote:

 
> > I wouldn't change logic on this. There's no reason to call this
> > function if it isn't doing anything.
> > 
> > I'll change this to just do the update and not change logic like this.
> 
> Fewer #ifdefs
> 

And there's other ways to fix it (like using an #else), but that is
off-topic to the current change set. In other words, that change should
be separate, as I don't want discussions on what's the best use of
#ifdefs distracting from getting in the "void seq_printf()" changes.

-- Steve

