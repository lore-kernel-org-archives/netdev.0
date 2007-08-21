From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/4 - rev 2] Initilize and populate age field
Date: Tue, 21 Aug 2007 13:27:35 +0200
Message-ID: <20070821112735.GO32236@postel.suug.ch>
References: <20070820134617.1226c97b.varunc@linux.vnet.ibm.com> <20070821105542.GN32236@postel.suug.ch> <46CACAFB.8050709@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	socketcan@hartkopp.net, shemminger@linux-foundation.org,
	krkumar2@in.ibm.com, varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53966 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591AbXHUL1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2007 07:27:15 -0400
Content-Disposition: inline
In-Reply-To: <46CACAFB.8050709@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Varun Chandramohan <varunc@linux.vnet.ibm.com> 2007-08-21 16:52
> I know its a bit confusing but let me explain the reason. In my first
> version patch i used fn_hash_insert() (place where alias is created)as
> place to insert my current time in the age field.
> This will eventually call fib_dump_info() for inserting the age filed
> attribute into the skb. Now in both places i have to call
> do_gettimeofday(). Its obvious that i need it in fn_hash_insert(), its
> also need in fib_dump_info() as it is the same function called for
> retrieving and dumping the age value to the userspace. So as you are
> aware that before we dump it to userspace we need to subtract the value
> with current time i need to call do_gettimeofday() twice. To avoid this
> i did as above.

At least put a comment there, it's far from obvious.
