From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] connector: bump skb->users before callback invocation
Date: Mon, 04 Jan 2016 21:47:33 -0500 (EST)
Message-ID: <20160104.214733.921867451376206917.davem@davemloft.net>
References: <CACT4Y+bKYO2XfY74tgUiOC7WotQ8DRBcMT=2yy3S=Ubz8bnj_g@mail.gmail.com>
	<20151231132633.GA30790@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, herbert@gondor.apana.org.au, tgraf@suug.ch,
	daniel@iogearbox.net, chamaken@gmail.com,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com, zbr@ioremap.net
To: fw@strlen.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151231132633.GA30790@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>
Date: Thu, 31 Dec 2015 14:26:33 +0100

> Dmitry reports memleak with syskaller program.
> Problem is that connector bumps skb usecount but might not invoke callback.
> 
> So move skb_get to where we invoke the callback.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied and queued up for -stable, thanks.
