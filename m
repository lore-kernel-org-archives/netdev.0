From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 01:31:59 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609083159.GH20613@netnation.com>
References: <20030609065211.GB20613@netnation.com> <20030608.235622.38700262.davem@redhat.com> <20030609081803.GF20613@netnation.com> <20030609.012202.68055632.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030609.012202.68055632.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, Jun 09, 2003 at 01:22:02AM -0700, David S. Miller wrote:

>    Hmm...It looks like this is still freeing the entry.. Is it possible to
>    recycle the dst without reallocating it?
>    
> Yes, can you test the patch I just sent you?  We can modify that
> to recycle easily instead of freeing.

Cool.  I'll see if I can set something up to try that at work tomorrow. 
Insufficient hardware here at home.

> We spend a decent amount of time mucking with fib rules, turning
> off multiple-tables support would kill that, although I suspect
> you're actually using that :)

We use it occasionally for various things.  I'll try profiling with it
turned off to see how much of an impact it has.

Simon-
