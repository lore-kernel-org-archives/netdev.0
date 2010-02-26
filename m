From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] accounting for socket backlog
Date: Thu, 25 Feb 2010 21:52:48 -0800 (PST)
Message-ID: <20100225.215248.29533524.davem@davemloft.net>
References: <1267067593.16986.1583.camel@debian>
	<20100225.003124.183011848.davem@davemloft.net>
	<1267152253.16986.1655.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.shi@intel.com
To: yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751694Ab0BZFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 00:52:30 -0500
In-Reply-To: <1267152253.16986.1655.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yi <yi.zhu@intel.com>
Date: Fri, 26 Feb 2010 10:44:13 +0800

> On Thu, 2010-02-25 at 16:31 +0800, David Miller wrote:
>> Right now we can queue up a lot and still get it to the application
>> if it is slow getting scheduled onto a cpu, but if you put this
>> limit here it could result in lots of drops. 
> 
> Or we can replace the sk->sk_rcvbuf limit with a backlog own limit. We
> can queue "a lot", but not endless. We have to have a limit anyway.

Simply using (2 * sk->sk_rcvbuf) might be sufficient enough.
