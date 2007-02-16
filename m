From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 09:10:51 +0100
Message-ID: <20070216081051.GC1599@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:36953 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1423416AbXBPIHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 03:07:36 -0500
Content-Disposition: inline
In-Reply-To: <45D55FF0.8090309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 11:40:32PM -0800, Ben Greear wrote:
...
> Maybe there should be something like an ASSERT_NOT_RTNL() in the 
> flush_scheduled_work()
> method?  If it's performance criticial, #ifdef it out if we're not 
> debugging locks?

Yes! I thought about the same (at first). But in my
opinion it was not enough, so I thought about doing
this in flush_workqueue. But in my next opinion it
was not enough too. Now I think something like this
should be done in rtnl_lock (under some debugging #if
of course). 

Cheers,
Jarek P.
