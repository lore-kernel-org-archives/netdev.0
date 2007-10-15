From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Mon, 15 Oct 2007 10:05:01 -0700
Message-ID: <1192467902.4556.54.camel@localhost>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>
	 <47067A2F.5020603@garzik.org> <1192464021.4556.49.camel@localhost>
	 <47139350.8010209@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3893 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932241AbXJORFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 13:05:15 -0400
In-Reply-To: <47139350.8010209@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-10-15 at 09:20 -0700, Kok, Auke wrote:
> > Instead the fix should be for the 2 existing bugs on macro:
> > o Comma after KERN_DEBUG
> > o Semicolon in macro
> will push a patch, thanks.

Perhaps you could fix this one too?

$ grep -P -r --include=*.[ch] "\bprintk\s*\(\s*KERN_[A-Z]+\s*\," *
drivers/net/ucc_geth_mii.c:#define vdbg(format, arg...) printk(KERN_DEBUG , format "\n" , ## arg)



