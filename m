From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch: net and drivers/net: Warn on missing blank
 line after variable declaration
Date: Thu, 6 Mar 2014 15:35:30 -0800
Message-ID: <20140306153530.bd61c160ba6f7872d6967b2e@linux-foundation.org>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
	<1394104390-23477-1-git-send-email-kys@microsoft.com>
	<20140306.142919.763823800315842610.davem@davemloft.net>
	<1394148520.16156.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kys@microsoft.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, apw@canonical.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394148520.16156.8.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 06 Mar 2014 15:28:40 -0800 Joe Perches <joe@perches.com> wrote:

> Networking prefers this style, so warn when it's not used.
> 
> Networking uses:
> 
> void foo(int bar)
> {
> 	int baz;
> 
> 	code...
> }
> 
> not
> 
> void foo(int bar)
> {
> 	int baz;
> 	code...
> }
> 
> There are a limited number of false positives when using
> macros to declare variables like:
> 
> WARNING: networking uses a blank line after declarations
> #330: FILE: net/ipv4/inet_hashtables.c:330:
> +	int dif = sk->sk_bound_dev_if;
> +	INET_ADDR_COOKIE(acookie, saddr, daddr)

um wait wut wot.

*All* kernel code uses blank line between end-of-locals and
start-of-code.  Or if it doesn't it should, thwap.

Why are we special-casing net/?
