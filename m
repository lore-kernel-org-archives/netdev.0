From: Tim Gardner <timg@tpi.com>
Subject: Re: ARP does not scale
Date: Sat, 13 Mar 2004 20:56:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403132056.24417.timg@tpi.com>
References: <200403131129.51083.timg@tpi.com> <20040313233222.GB19737@krispykreme>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040313233222.GB19737@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Saturday 13 March 2004 16:32, Anton Blanchard wrote:
> [moving this to netdev]

Anton,

I figured out how to subscribe.

> It would be nice to fix this properly in 2.6, a CONFIG option for this sort
> of thing is painful for distros.
>
> Check out net/ipv4/tcp.c and how it makes an effort to scale tcp_ehash and
> tcp_bhash with memory and also allows an override with a cmdline option
> thash_entries.
>
> Anton
>

I checked out how tcp_ehash and tcp_bhash auto-size based on the amount of 
RAM. I think one can usually make the same assumption about the relative 
number of ARP entries. I say usually because I have some core routers that 
have over a thousand ARP entries. In that case I would like to override the 
auto-size calculation so that I can force enough hash buckets such that there 
is never (or rarely) a hash collision.

How about a compromise. Leave in the config option, but default it to 0 which 
enables the auto-size algorithm. Otherwise, use the size specified in the 
config option. 

rtg
-- 
Tim Gardner - timg@tpi.com
www.tpi.com 406-443-5357 
