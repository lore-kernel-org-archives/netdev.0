From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP
 SNMP counter values
Date: Sun, 11 Oct 2015 16:37:10 -0700
Message-ID: <1444606630.27760.153.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151011205528.GA4322@benjojo.co.uk>
	 <1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
	 <1444603382.27760.146.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1444603443.27760.147.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1444604969.27760.149.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAL=9YSUt2j6tgP2OXntHn-_TcFz4i_=WQ9fo86sEZBLW9afbvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ben+patches@benjojo.co.uk,
	David L Stevens <dlstevens@us.ibm.com>
To: Ben Cox <ben@benjojo.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33217 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbbJKXhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 19:37:12 -0400
In-Reply-To: <CAL=9YSUt2j6tgP2OXntHn-_TcFz4i_=WQ9fo86sEZBLW9afbvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please do not top-post on netdev and/or lkml


On Mon, 2015-10-12 at 00:14 +0100, Ben Cox wrote:
> Nice!
> 
> That works in my head at least, Sorry about not seeing that fairly
> glaring memory issue there.

No problem, this is why we review patches ;)

> 
> Are you sure " skb->transport_header += iphlen; " won't have a knock
> on affect when it's given to NF_HOOK ( as in, would a potential
> userspace program get something it does not expect anymore ) ?


netfilter does not depend on transport_header being set (otherwise as
you can see RAW packets would have problems with netfilter since the
very beginning.


> How does submission work at this point if the above is not a issue
> (apologies if this is already in a FAQ somewhere I missed)?
> 

Just send a V2 of the patch, using following title :

[PATCH v2 net] raw: increment correct SNMP counters for ICMP messages


I'll add my 'Acked-by:' after your 'Signed-off-by:'

Thanks !
