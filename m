From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close
 connection
Date: Thu, 26 Aug 2010 13:07:28 +0100
Message-ID: <1282824448.2263.3.camel@achroite.uk.solarflarecom.com>
References: <20100825.153424.246521475.davem@davemloft.net>
	 <1282785886.22839.199.camel@localhost>
	 <20100826125357.F667.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100826125357.F667.A69D9226@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-26 at 12:55 +0900, KOSAKI Motohiro wrote:
[...]
> Cool!
> 
> Ben, I think your code is cleaner than mine. If you allow me, I hope to
> include this one into my patch description.

You can do that if you like, but it seems a bit long for a commit
message.

By the way, I was able to reproduce this bug in RHEL 3 (kernel based on
2.4.21) so it seems to have been around for a while.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
