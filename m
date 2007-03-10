From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full length for sticky options.
Date: Fri, 9 Mar 2007 16:22:53 -0800
Message-ID: <20070310002253.GX10574@sequoia.sous-sol.org>
References: <20070309.101328.78855655.yoshfuji@linux-ipv6.org> <20070308.204845.125566290.davem@davemloft.net> <20070309234435.GE7920@sequoia.sous-sol.org> <20070309.161506.70220159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chrisw@sous-sol.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:47351 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767684AbXCJAWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 19:22:19 -0500
Content-Disposition: inline
In-Reply-To: <20070309.161506.70220159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller (davem@davemloft.net) wrote:
> copy_to_user() will check it, actually, it will make sure that
> optval + len doesn't wrap or overlap into kernel space.
> 
> Actually, like sparc64 it BUG's on negative length so we have
> to fix this :-)

Yeah, I think it's arch dependent (x86_64 for example will give
me 2GB back happily, useful if I forgot my password ;-)

thanks,
-chris
