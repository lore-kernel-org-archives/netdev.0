From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [PATCHSET] packet mark & fib rules work
Date: Thu, 9 Nov 2006 11:46:04 +0000
Message-ID: <20061109114604.GA32395@fogou.chygwyn.com>
References: <20061109112735.577771022@lsx.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:40156 "EHLO fogou.chygwyn.com")
	by vger.kernel.org with ESMTP id S965684AbWKILw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:52:59 -0500
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061109112735.577771022@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Nov 09, 2006 at 12:27:35PM +0100, Thomas Graf wrote:
> Renames nfmark to mark and remove the dependency on netfilter
> to ease usage by all subsystems. Also removes all the unneeded
> config options to enable routing by fwmark, it can be safely
> enabled by default.
> 
> Moves mark selector code from per protocol part into the generic
> part and adds support for inverting selectors.
> 

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

so far as all the DECnet bits go. One question though... will you
be adding later (as your slide #5 and #11 from your netconf presentation
appear to imply) a way to set the mark from the routing table (presumably
included in the nexthop info) ?

Steve.

