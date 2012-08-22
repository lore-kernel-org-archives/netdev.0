From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [GIT] Networking
Date: Wed, 22 Aug 2012 01:08:22 +0100
Message-ID: <20120822000822.GL23464@ZenIV.linux.org.uk>
References: <20120821.163823.1448570709635488157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120821.163823.1448570709635488157.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2012 at 04:38:23PM -0700, David Miller wrote:

> 8) Fix all the netprio file handling bugs found by Al Viro, from John
>    Fastabend.

Great, I was just about to start figuring out how to deal with inter-tree
dependencies; now I'll just rebase my internal queue ;-)  (I've added
iterate_fd(files, from, callback) that goes through the descriptor
table starting at given fd, calling the non-blocking callback for files in
there until the callback returns 0; that kills open-coded loops of that
kind in tty_io and netprio, as well as most of the crap in selinux
flush_unauthorized_files(); for now I just have a copy of John's patch
in my tree, but if it's about to go into the mainline - great, less
potential PITA for me).
