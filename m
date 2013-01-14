From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pkt_sched: namespace aware ifb
Date: Sun, 13 Jan 2013 21:40:16 -0800
Message-ID: <1358142016.8744.1750.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
	 <1358046374.20249.1789.camel@edumazet-glaptop>
	 <20130113035013.GJ5259@kvack.org>
	 <1358056199.20249.2121.camel@edumazet-glaptop>
	 <50F2C860.1060602@mojatatu.com>  <20130113164141.GL5259@kvack.org>
	 <1358096257.8744.112.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:55080 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab3ANFkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 00:40:19 -0500
Received: by mail-pb0-f45.google.com with SMTP id mc8so1955692pbc.4
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 21:40:18 -0800 (PST)
In-Reply-To: <1358096257.8744.112.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-13 at 08:57 -0800, Eric Dumazet wrote:
> On Sun, 2013-01-13 at 11:41 -0500, Benjamin LaHaise wrote:

> > pkt_sched: namespace aware ifb v2
> > 
> > Eric Dumazet pointed out that act_mirred needs to find the current net_ns,
> > and struct net pointer is not provided in the call chain.  His original
> > patch made use of current->nsproxy->net_ns to find the network namespace,
> > but this fails to work correctly for userspace code that makes use of
> > netlink sockets in different network namespaces.  Instead, pass the
> > "struct net *" down along the call chain to where it is needed.
> > 
> > Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
> > ---
> 
> OK I'll test it at the end of the (sunny) day.
> 

Could you resend the patch without the ifb part, I tested it
and it worked well for me, thanks !
