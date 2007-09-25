From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Tue, 25 Sep 2007 08:33:03 -0700
Message-ID: <20070925083303.6c1f7701@freepuppy.rosehill>
References: <20070925122029.15989.0@janus.isnogud.escape.de>
	<20070925122243.15989.2@janus.isnogud.escape.de>
	<20070925124138.GC18348@ghostprotocols.net>
	<ygfr6kmev3i.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45728 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756013AbXIYPfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 11:35:21 -0400
In-Reply-To: <ygfr6kmev3i.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25 Sep 2007 15:24:33 +0200
Urs Thuermann <urs@isnogud.escape.de> wrote:

> Arnaldo Carvalho de Melo <acme@ghostprotocols.net> writes:
> 
> > > +	skb_queue_purge(&sk->sk_receive_queue);
> > > +	if (sk->sk_protinfo)
> > > +		kfree(sk->sk_protinfo);
> > > +}
> > 
> > Is it really needed to do this sk_protinfo check?
> 
> Thanks for finding this.  This is from 2.6.12 times or so.  We have
> other CAN protocol (which we are not allowed to put under GPL)
> implemenatations which still use the protinfo field.  But we should
> change those and I will delete this check.
> 
> urs

Then please make all exported symbols marked EXPORT_SYMBOL_GPL to make
sure that the other CAN protocol can not reuse your infrastructure.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
