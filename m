From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Increase snd/rcv buffers in pppoe
Date: 23 Feb 2004 12:16:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040223111659.GB10681@colin2.muc.de>
References: <20040222234750.GA78924@colin2.muc.de> <20040222232601.481b8c57.davem@redhat.com> <20040223105359.GA91938@colin2.muc.de> <20040223.200101.39143636.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@muc.de, davem@redhat.com, netdev@oss.sgi.com,
        mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 23 Feb 2004 12:16:59 +0100
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040223.200101.39143636.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 23, 2004 at 08:01:01PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> In article <20040223105359.GA91938@colin2.muc.de> (at 23 Feb 2004 11:53:59 +0100,Mon, 23 Feb 2004 11:53:59 +0100), Andi Kleen <ak@muc.de> says:
> 
> > -#define SK_WMEM_MAX	65535
> > -#define SK_RMEM_MAX	65535
> > +#define SK_WMEM_MAX    131072
> > +#define SK_RMEM_MAX	131072
> 
> 131071?

Probably, but it doesn't make any difference; see how the skbuff socket
accounting works. Really there isn't really a need to make it power 
of two (except for mystifying arbitary magic numbers for the users ;-) 
130000 or 200000 would do as well.

-Andi
