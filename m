From: Steven Kath <steven.kath@vyatta.com>
Subject: Re: any way to reset all marked connections when using CONNMARK?
Date: Fri, 11 Feb 2011 14:11:56 -0800 (PST)
Message-ID: <426866445.661.1297462316364.JavaMail.root@tahiti.vyatta.com>
References: <256863566.648.1297461959805.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42147 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757072Ab1BKWL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 17:11:57 -0500
In-Reply-To: <256863566.648.1297461959805.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- "Chris Friesen" <chris.friesen@genband.com> wrote: -----
> We've got a scenario where we want to use CONNMARK to mark connections
> that have passed a large number of rules in order to allow packets
> from those connections to skip rules in the future (for performance
> reasons).
> 
> However, when we add new rules we want to ensure that all the
> connections need to pass the new rules as well.
> 
> It has been proposed to add a custom patch to clear the mark for all
> marked connections--is there a better way of doing this?
> 
> I thought maybe we could use the CONNMARK as a generation count and
> bumping it up each time a rule is added. This would require updating
> the bypass rule each time we modify the other rules though. If there
> are better options I'd like to hear them.

Using conntrack-tools might help:

conntrack --update --mark 0

