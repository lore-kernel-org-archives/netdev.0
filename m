From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: [nicstar] using dev_alloc_skb() (reported by
 "Johnston, Jayme" <Jayme.Johnston@siemens.com>)
Date: Fri, 9 Apr 2004 16:38:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409163818.7e2b6f71.davem@redhat.com>
References: <200404071211.i37CB3gK020805@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200404071211.i37CB3gK020805@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 07 Apr 2004 08:11:04 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> the nicstar driver has typically used alloc_skb() to get its i/o buffers.
> since these buffers are likely to be passed to the network stack at some
> point it should probably be using dev_alloc_skb().  this patches fixes
> a crash during pppoatm operation when an unchecked skb_push() operates on
> a buffer returned by the nicstar.
> 
> please apply to 2.6 and 2.4 kernels (and if at all possible could
> i get this in the soon to be released 2.4.26 kernel?)

Good catch, applied.

I'll do my best to get Marcelo to eats this soon, but no promises.
:-)
