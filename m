From: Andrew Morton <akpm@osdl.org>
Subject: Re: [IPV4] Fix ip_rt_gc_min_interval_ms procfs/sysctl
Date: Fri, 18 Feb 2005 03:09:50 -0800
Message-ID: <20050218030950.02d628cf.akpm@osdl.org>
References: <20050218.192430.98634850.yoshfuji@linux-ipv6.org>
	<20050218024917.2e5c19ec.akpm@osdl.org>
	<20050218030222.51fcc83f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: yoshfuji@linux-ipv6.org, torvalds@osdl.org, davem@davemloft.net,
        netdev@oss.sgi.com
In-Reply-To: <20050218030222.51fcc83f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Seems to me a simpler fix would be to make it a long?

That doesn't work either, does it?  gc_min_interval is in seconds.

OK, I give up - we need a whole batch of new conversion functions.  How sad.
