From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Sun, 11 Jan 2015 22:08:29 -0500 (EST)
Message-ID: <20150111.220829.865175509346236586.davem@davemloft.net>
References: <20150112140515.369eb687@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com,
	vlee@twopensource.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150112140515.369eb687@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 12 Jan 2015 14:05:15 +1100

> Hi all,
> 
> After merging the net-next tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> Documentation/networking/timestamping/txtimestamp.c: In function '__recv_errmsg_cmsg':
> Documentation/networking/timestamping/txtimestamp.c:205:33: error: dereferencing pointer to incomplete type
> Documentation/networking/timestamping/txtimestamp.c:206:23: error: dereferencing pointer to incomplete type
> 
> Caused by commit cd91cc5bdddf ("doc: fix the compile error of
> txtimestamp.c").  On (at least) Debian stable, the system's definition
> of struct in6_pktinfo depends on __USE_GNU being defined (at least, I
> think that is the problem).
> 
> I have reverted that commit for today.

It's fixed as of 5 minutes ago in the net-next tree, sorry for this.
