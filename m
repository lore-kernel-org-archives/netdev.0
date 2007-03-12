From: David Miller <davem@davemloft.net>
Subject: Removal of multipath cached (was Re: [PATCH] [REVISED]
 net/ipv4/multipath_wrandom.c: check kmalloc() return value.)
Date: Mon, 12 Mar 2007 13:53:11 -0700 (PDT)
Message-ID: <20070312.135311.71086996.davem@davemloft.net>
References: <20070308.232908.92582631.davem@davemloft.net>
	<20070312115137.GA3270@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amit2030@gmail.com, linux-kernel@vger.kernel.org, akpm@osdl.org,
	netdev@vger.kernel.org
To: jarkao2@o2.pl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932203AbXCLUxQ@vger.kernel.org>
In-Reply-To: <20070312115137.GA3270@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 12 Mar 2007 12:51:37 +0100

> But until then it'll unnecessarily spoil linux opinion as regards
> stability and waste time of developers to check error messages.
> So, maybe it's less evil to check those NULLs where possible and add
> some WARN_ONs here and there...

It's a crash either way, so zero improvement.

And _THIS_ is my big problem with the multi-path cached code in the
kernel.

NOBODY wants to step up and fix the code, but people refuse to let it
get removed from the tree.  That is totally unacceptable, so I'm going
to FIX THIS.

I'm going to FIX IT by saying that if nobody steps up to the plate to
fix the multipath cached code by 2.6.23 IT IS GONE forver.

And there is absolutely no negotiations about this, I've held back on
this for nearly 2 years, and nothing has happened, this code is not
maintained, nobody cares enough to fix the bugs, and even no
distributions enable it because it causes crashes.
