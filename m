From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][GENETLINK] introduce command names
Date: Mon, 4 Dec 2006 10:28:57 +0100
Message-ID: <20061204092857.GO8693@postel.suug.ch>
References: <1165061496.3564.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:39822 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1759883AbWLDJ2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 04:28:37 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165061496.3564.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-02 07:11
> [GENETLINK] introduce command names
> 
> Introduce optional command names.
> While command names can be put in user space by the author of the
> command, this alleviates things for the discovery process without
> requiring any user space code written.
> In a recent tutorial that i gave, the desire for this feature was
> the highest.

I assume you're planning to export this to userspace at some point?
What's the real advantage besides that when listing avaiable
operations we can output names instead of numbers? Userspace should
be aware of operation numbers when using it. I'm all for this if
the direction is to move towards having some form of scriptable
genetlink tool which can be used to communicate with simple genetlink
families.

I guess the desire was the highest because you sold it as such :-)
