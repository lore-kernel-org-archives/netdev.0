From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Thu, 22 Feb 2007 00:27:04 -0800 (PST)
Message-ID: <20070222.002704.34758758.davem@davemloft.net>
References: <45D97D5D.9040101@gmail.com>
	<45D97DC9.1030305@gmail.com>
	<45DA0FD6.9020404@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani@gmail.com, netdev@vger.kernel.org,
	andrea.baiocchi@uniroma1.it, francesco@net.infocom.uniroma1.it
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751456AbXBVI1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:27:05 -0500
In-Reply-To: <45DA0FD6.9020404@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 19 Feb 2007 16:00:06 -0500

> I'd prefer to make it apply automatically across all congestion controls 
> that do slow-start, and also make the max_ssthresh parameter 
> controllable via sysctl.  This patch (attached) should implement this. 
> Note the default value for sysctl_tcp_max_ssthresh = 0, which disables 
> limited slow-start.  This should make ABC apply during LSS as well.
> 
> Note the patch is compile-tested only!  I can do some real testing if 
> you'd like to apply this Dave.

I'll apply this, but could you please also when making suggestions
like this provide the patch necessary to kill the function added for
YeaH and the call site in the YeaH algorithm?

When people post conflicting code bits for this for inclusion, it
makes work very difficult for me.

What I want to do right now is back everything out and let you guys
sort it out, but I don't want to do that because it would mean that
I just wasted an entire hour reviewing the YeaH patches. :-/

