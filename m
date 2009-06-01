From: Tom Goff <thomas.goff@boeing.com>
Subject: Re: PIM-SM namespace changes
Date: Mon, 1 Jun 2009 13:28:34 -0700
Message-ID: <20090601202834.GA27821@boeing.com>
References: <20090518.222429.135907168.davem@davemloft.net> <20090520004344.GA10143@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:37609 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbZFAU2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 16:28:43 -0400
Content-Disposition: inline
In-Reply-To: <20090520004344.GA10143@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2009 at 05:43:44PM -0700, Tom Goff wrote:
> > Some bugs to fix before I can apply these Tom.
> ...
> > Also we need to seriously discuss how now we unconditionally
> > register the PIM protocols.  Before we had a policy of only
> > doing so conditionally, and that's a change that needs to
> > be carefully considered and discussed.
> 
> Thanks for the feedback, I think the patch below includes proper error
> handling.
> 
> For protocol registration I see three basic approaches for using PIM
> with namespaces:
> 
>   - unconditionally add PIM when multicast routing is initialized
>     (maybe only ifdef CONFIG_NET_NS, otherwise preserve the current
>     behavior)
> 
>   - keep a count of the number of namespaces that have enabled PIM and
>     add/delete PIM when transitioning from/to zero
> 
>   - make all or some protocol registration per network namespace
> 
> There are obviously tradeoffs and I would appreciate any
> comments/suggestions on alternatives that allow namespace use of
> dynamically enabled protocols.
> 
[patch omitted]

Any further thoughts on handling PIM/namespace interaction?

  Tom
