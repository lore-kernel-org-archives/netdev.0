From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [PATCH][RFC] Infrastructure for compact call location
	representation
Date: Tue, 8 Jun 2010 11:59:54 -0700
Message-ID: <20100608185954.GC31503@dvomlehn-lnx2.corp.sa.net>
References: <20100608003052.GA29377@dvomlehn-lnx2.corp.sa.net> <20100608084452.9a3ebb0a.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: to@dvomlehn-lnx2.corp.sa.net, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:59199 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755236Ab0FHS7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:59:55 -0400
Content-Disposition: inline
In-Reply-To: <20100608084452.9a3ebb0a.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 08, 2010 at 08:44:52AM -0700, Randy Dunlap wrote:
> On Mon, 7 Jun 2010 17:30:52 -0700 David VomLehn wrote:
> 
> > Notes
> > o	Under simple test conditions, the number of call site IDs allocated
> > 	can be quite small, small enough to fit in 6 bits. That would reduce
> > 	the sk_buff growth to one byte. This is *not* a recommended
> > 	configuration.
> > o	This is placed in net/core and linux/net since those are the only
> > 	current users, but there is nothing about this that is networking-
> > 	specific.
> 
> => this shouldn't end up in net/

I was hesitant to do so, but I've now moved the header files
to include/linux/ and the C file to lib/. This makes more sense to me.

The rest of your comments were bang on; I've made all of the changes you
suggested. Thanks!
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***

-- 
David VL
