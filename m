From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETDEBUG network triggerable messages in IPv6
Date: Fri, 9 Apr 2004 19:50:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409195052.10ba931c.ak@suse.de>
References: <20040409182125.348fd6cd.ak@suse.de>
	<20040410.021840.113165465.yoshfuji@linux-ipv6.org>
	<20040409193123.63e4cdc7.ak@suse.de>
	<20040410.024705.97089877.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040410.024705.97089877.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 10 Apr 2004 02:47:05 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:


> 
> I'd prefer:
> 
>   if (net_ratelimit())
>     NETDEBUG_PRINTK("overrun destopt\n"..)

This won't optimize away the function call.

> or
> 
>   NETDEBUG_PRINTK_LIMIT("overrun destopt\n"..)
> 
> (or something like this) much more.

... and this will make the lines even longer.

-Andi
