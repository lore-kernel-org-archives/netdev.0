From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Netfilter: New target: RLOG
Date: Thu, 19 Jan 2012 10:25:33 +0100
Message-ID: <20120119092533.GA32602@1984>
References: <1326926610-17830-1-git-send-email-rw@linutronix.de>
 <20120119091248.GA32391@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rostedt@goodmis.org
To: Richard Weinberger <rw@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120119091248.GA32391@1984>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2012 at 10:12:48AM +0100, Pablo Neira Ayuso wrote:
> I still think this can be useful.
> 
> But, why don't you add this to the LOG target as an extension instead
> of yet another target?

By "extension", I meant to say "revision".

If you're not familiar with the iptables revision mechanism, for
instance, have a look at net/netfilter/xt_NFQUEUE.c

Look for the "revision" pattern in that code. Basicaly, it allows you
to enhance existing matches/targets without breaking backward
compatibility.
