From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] more improvement to dev_alloc_name -- strnchr
Date: Mon, 19 Jan 2004 13:07:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119130744.324f582b.shemminger@osdl.org>
References: <1074302619.40088e9bd44a6@www.geekmail.cc>
	<20040119113204.5913a8d6.shemminger@osdl.org>
	<20040119210605.3cea32b0.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, ap@cipherica.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040119210605.3cea32b0.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 21:06:05 +0100
Andi Kleen <ak@suse.de> wrote:

> On Mon, 19 Jan 2004 11:32:04 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > +#ifndef __HAVE_ARCH_STRNCHR
> 
> Please drop the ifdef. Don't want to encourage anybody to write
> strrchr() in assembly.
> 
> -Andi

I assume you mean strnchr not strrchr. Mainly just following the style
of all the other string routines.
What if gcc does it inline in some future version?
