From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 1/2] tun: reserves space for network in skb
Date: Thu, 9 Jun 2011 07:16:51 -0700 (PDT)
Message-ID: <1809430734.67816.1307629011701.JavaMail.root@tahiti.vyatta.com>
References: <20110609.000914.359816474597759076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58245 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052Ab1FIOQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 10:16:52 -0400
In-Reply-To: <20110609.000914.359816474597759076.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 08 Jun 2011 17:33:07 -0700
> 
> > The tun driver allocates skb's to hold data from user and then
> > passes the data into the network stack as received data. Most
> > network devices
> > allocate the receive skb with routines like dev_alloc_skb() that
> > reserves additional space for use by network protocol stack but tun
> > does not.
> >
> > Because of the lack of padding, when the packet is passed through
> > bridge netfilter a new skb has to be allocated.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Netconf must be coming up soon, Stephen Hemminger is submitting
> patches again :-)

12 hours on plane + 8 hours in airports tend to get the
trivial patch backlog moving again. 
