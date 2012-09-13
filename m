From: Florian Westphal <fw@strlen.de>
Subject: Re: xt_nat_init: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000000e0
Date: Thu, 13 Sep 2012 11:30:24 +0200
Message-ID: <20120913093024.GL14750@breakpoint.cc>
References: <20120913091629.GA28022@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	networking <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@gnumonks.org>,
	"Netfilter Development Maili..." <netfilter-devel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120913091629.GA28022@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fengguang Wu <fengguang.wu@intel.com> wrote:
> Hi Patrick,
> 
> This happens in today's linux-next tree and is pretty reproducible.
> [    1.834544] nf_conntrack version 0.5.0 (1786 buckets, 7144 max)
> [    1.835406] ctnetlink v0.93: registering with nfnetlink.
> [    1.836202] BUG: unable to handle kernel NULL pointer dereference at 00000000000000e0
> [    1.837539] IP: [<ffffffff81a19123>] mutex_lock_interruptible+0x23/0x70

Should be fixed by
commit 00545bec9412d130c77f72a08d6c8b6ad21d4a1e
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: netfilter: fix crash during boot if NAT has been compiled built-in

But seems its not yet in net-next.  Pablo?
