From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000e: fix debugging printout code
Date: Mon, 15 Oct 2007 10:32:10 -0700
Message-ID: <4713A41A.5050602@intel.com>
References: <20071004183843.31540.23710.stgit@localhost.localdomain>	 <47067A2F.5020603@garzik.org> <1192464021.4556.49.camel@localhost>	 <47139350.8010209@intel.com> <1192467902.4556.54.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58875 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762964AbXJORds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 13:33:48 -0400
In-Reply-To: <1192467902.4556.54.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> On Mon, 2007-10-15 at 09:20 -0700, Kok, Auke wrote:
>>> Instead the fix should be for the 2 existing bugs on macro:
>>> o Comma after KERN_DEBUG
>>> o Semicolon in macro
>> will push a patch, thanks.
> 
> Perhaps you could fix this one too?
> 
> $ grep -P -r --include=*.[ch] "\bprintk\s*\(\s*KERN_[A-Z]+\s*\," *
> drivers/net/ucc_geth_mii.c:#define vdbg(format, arg...) printk(KERN_DEBUG , format "\n" , ## arg)

Just send a patch yourself... :)

Auke
