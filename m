From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] more improvement to dev_alloc_name -- strnchr
Date: Mon, 19 Jan 2004 13:44:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119134429.2da42efb.davem@redhat.com>
References: <1074302619.40088e9bd44a6@www.geekmail.cc>
	<20040119113204.5913a8d6.shemminger@osdl.org>
	<20040119210605.3cea32b0.ak@suse.de>
	<20040119130744.324f582b.shemminger@osdl.org>
	<20040119221515.74629ac4.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, ap@cipherica.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040119221515.74629ac4.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 22:15:15 +0100
Andi Kleen <ak@suse.de> wrote:

> On Mon, 19 Jan 2004 13:07:44 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > What if gcc does it inline in some future version?
> 
> Not sure what it has to do with that. The #ifdef __HAVE_ARCH_* stuff 
> is that architectures with crazy enough hackers can add assembly
> optimized functions if they want. But it clearly doesn't make any sense
> with this function (in fact it doesn't make much sense with any string
> function except memset/memcpy), so better not encourage it.

Sometimes it is just used on a platform to force a call to the gcc builtin.

I think it's perfectly reasonable what Stephen has done.
