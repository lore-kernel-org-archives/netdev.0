From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Please revert disallowing zero listen queues
Date: Tue, 06 Mar 2007 11:11:42 -0800 (PST)
Message-ID: <20070306.111142.07639258.davem@davemloft.net>
References: <200703061332.09677@strip-the-willow>
	<20070306.103706.68156515.davem@davemloft.net>
	<45EDB8C8.3030302@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
	weid@np.css.fujitsu.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54930
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932778AbXCFTLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:11:48 -0500
In-Reply-To: <45EDB8C8.3030302@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 06 Mar 2007 10:54:00 -0800

> > So we're not "disallowing" a backlog argument of zero to
> > listen().  We'll accept that just fine, the only thing that
> > happens is that you'll get what you ask for, that being
> > no connections :-)
> 
> I'm not sure where HP-UX inherited the 0 = 1 bit - perhaps from BSD, nor 
> am I sure there is official chapter and verse, but:
> 
> <excerpt>
> backlog is limited to the range of 0 to SOMAXCONN, which is 	defined in 
> <sys/socket.h>.  SOMAXCONN is currently set to 4096.  If any other 
> value is specified, the system automatically assigns the closest value 
>      within the range.  A backlog of 0 specifies only 1 pending 
> connection      is allowed at any given time.
> </excerpt>
> 
> I don't have a Solaris, BSD or AIX manpage for listen handy to check 
> them but would not be surprised to see they are similar.

Ok, that seals the deal for me, I'll revert the change :)
