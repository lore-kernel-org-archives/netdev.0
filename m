From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Sat, 23 Jun 2007 17:13:21 +0200
Message-ID: <467D3891.4010906@hartkopp.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de> <467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net> <467D178B.8080503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: j.hadi123@gmail.com, Urs Thuermann <urs@isnogud.escape.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:30456 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757595AbXFWPOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2007 11:14:03 -0400
In-Reply-To: <467D178B.8080503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Oliver Hartkopp wrote:
>   
>> i was just looking through the mailings regarding your suggested changes
>> (e.g. in VLAN, DUMMY and IFB) an none of them currently went into the
>> kernel (..)
>>     
>
>
> They are all in the net-2.6.23 tree.
>   

Ah, ok - that wasn't on my radar as i missed the mail from Dave to you
at June 13th ...

@Dave: Please consider to schedule the PF_CAN stuff for inclusion into
2.6.23 also. Thx.

Btw. for next week, we'll ...

1. ... wait for Jamals feedback about skb->iif usage
2. ... move the vcan driver for the new netlink API

So that we can finally go for net-2.6.23 at the end of next week, if
there are no new issues from other reviewers until then.

@Patrick: The changes in dummy.c and ifb.c for the netlink support do
not look very complicated (not even for me ;-)) When these changes are
implemented, how do i create/remove my interfaces? Is there any
userspace tool like 'tc' for that?

Thx & regards,
Oliver


