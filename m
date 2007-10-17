From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] remove netpoll receive code
Date: Wed, 17 Oct 2007 13:41:24 -0700
Message-ID: <20071017134124.00f5633a.akpm@linux-foundation.org>
References: <20071017132131.1992bedd@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jason Wessel <jason.wessel@windriver.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44519 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbXJQUl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 16:41:27 -0400
In-Reply-To: <20071017132131.1992bedd@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007 13:21:31 -0700
Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> The netpoll receive code is:
> 1. Not used by any in-tree features, it is used by kgdb-over-ether.
> 2. A nice hook for people doing nasty things like private binary network stacks or rootkits.
> 3. Unsecured by any of the normal firewalling code.
> 
> Hopefully all distro's are smart enough to turn it off in their default config *nudge, nudge*.
> Doubly true for any distribution that claims to be secure or enterprise ready.
> 
> I propose that we take out all the whole netpoll rx path. If/when kgdb gets submitted
> a better and alternative receive path can be added.
> 

umm, let's cc the kgdb maintainer.
