From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 25 Sep 2007 15:24:33 +0200
Message-ID: <ygfr6kmev3i.fsf@janus.isnogud.escape.de>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122243.15989.2@janus.isnogud.escape.de>
	<20070925124138.GC18348@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:46551 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbXIYN0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2007 09:26:07 -0400
In-Reply-To: <20070925124138.GC18348@ghostprotocols.net>; from Arnaldo Carvalho de Melo on Tue, 25 Sep 2007 09:41:38 -0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:

> > +	skb_queue_purge(&sk->sk_receive_queue);
> > +	if (sk->sk_protinfo)
> > +		kfree(sk->sk_protinfo);
> > +}
> 
> Is it really needed to do this sk_protinfo check?

Thanks for finding this.  This is from 2.6.12 times or so.  We have
other CAN protocol (which we are not allowed to put under GPL)
implemenatations which still use the protinfo field.  But we should
change those and I will delete this check.

urs
