From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [NET]: Please revert disallowing zero listen queues
Date: Tue, 06 Mar 2007 10:54:00 -0800
Message-ID: <45EDB8C8.3030302@hp.com>
References: <200703061332.09677@strip-the-willow> <20070306.103706.68156515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
	weid@np.css.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:40578 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030358AbXCFSyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:54:14 -0500
In-Reply-To: <20070306.103706.68156515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So we're not "disallowing" a backlog argument of zero to
> listen().  We'll accept that just fine, the only thing that
> happens is that you'll get what you ask for, that being
> no connections :-)

I'm not sure where HP-UX inherited the 0 = 1 bit - perhaps from BSD, nor 
am I sure there is official chapter and verse, but:

<excerpt>
backlog is limited to the range of 0 to SOMAXCONN, which is 	defined in 
<sys/socket.h>.  SOMAXCONN is currently set to 4096.  If any other 
value is specified, the system automatically assigns the closest value 
     within the range.  A backlog of 0 specifies only 1 pending 
connection      is allowed at any given time.
</excerpt>

I don't have a Solaris, BSD or AIX manpage for listen handy to check 
them but would not be surprised to see they are similar.

rick jones
