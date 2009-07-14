From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [GIT]: Networking
Date: Tue, 14 Jul 2009 21:12:26 +0100
Message-ID: <20090714211226.6d653016@lxorguk.ukuu.org.uk>
References: <20090714.122704.21107059.davem@davemloft.net>
	<20090714203123.0ab1f7b8@lxorguk.ukuu.org.uk>
	<20090714.123405.181074517.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg@kroah.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756256AbZGNULf@vger.kernel.org>
In-Reply-To: <20090714.123405.181074517.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 14 Jul 2009 12:34:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Date: Tue, 14 Jul 2009 20:31:23 +0100
> 
> >> 8) Locking fix in TTY based networking drivers, from Ralf Baechle.
> > 
> > I thought we had established that this one was wrong following further
> > discussion. The tty drivers that were calling up from IRQ handlers have
> > been fixed by the cull of bogus tty->low_latency setting.
> 
> Where was this change made?
> 
> At a minimum it likely needs to be added to the -stable trees.

No - the fix that needs to be in the stable trees is the one removing the
bogus tty->low_latency settings. The standard tty layer blows up in all
sorts of other ways with these driver bugs and I thought they'd been
pushed back into -stable. Will check with GregKH as I think they went via
his tree.
