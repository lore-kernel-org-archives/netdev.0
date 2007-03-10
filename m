From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full length for sticky options.
Date: Fri, 9 Mar 2007 16:30:58 -0800
Message-ID: <20070310003058.GZ10574@sequoia.sous-sol.org>
References: <20070309.101328.78855655.yoshfuji@linux-ipv6.org> <20070308.204845.125566290.davem@davemloft.net> <20070309234435.GE7920@sequoia.sous-sol.org> <20070309.161759.69218776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:60811 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767685AbXCJAaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 19:30:23 -0500
Content-Disposition: inline
In-Reply-To: <20070309.161759.69218776.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller (davem@davemloft.net) wrote:
> 
> Ugh, Chris, why is this patch against a copy of ipv6_sockglue.c
> that doesn't have the NULL pointer fix applied?
> 
> Nevermind, it's obvious, so I fixed it up by hand, but please
> patch against current sources expecially when we're all aware
> of other fixes that have been made to this exact function over
> the past few days.  Otherwise it makes a lot more work for me.

Shoot, I'm sorry.  I pulled from Linus' tree, then your tree to have
most uptodate specifically to make sure I had the lastest changes.
Not sure how that went wrong.

thanks,
-chris
