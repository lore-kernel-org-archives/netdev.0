From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 14 Jul 2009 13:15:52 -0700 (PDT)
Message-ID: <20090714.131552.07104766.davem@davemloft.net>
References: <20090714203123.0ab1f7b8@lxorguk.ukuu.org.uk>
	<20090714.123405.181074517.davem@davemloft.net>
	<20090714211226.6d653016@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	greg@kroah.com
To: alan@lxorguk.ukuu.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756311AbZGNUPt@vger.kernel.org>
In-Reply-To: <20090714211226.6d653016@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 14 Jul 2009 21:12:26 +0100

> On Tue, 14 Jul 2009 12:34:05 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> At a minimum it likely needs to be added to the -stable trees.
> 
> No - the fix that needs to be in the stable trees is the one removing the
> bogus tty->low_latency settings. The standard tty layer blows up in all
> sorts of other ways with these driver bugs and I thought they'd been
> pushed back into -stable. Will check with GregKH as I think they went via
> his tree.

Understood.

I've reverted this change from the net-2.6 tree, thanks for
explaining.

Linus, please pull, this has been sorted out.
