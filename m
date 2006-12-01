From: David Miller <davem@davemloft.net>
Subject: Re: RFC: remove NET_CLS_POLICE?
Date: Thu, 30 Nov 2006 19:52:08 -0800 (PST)
Message-ID: <20061130.195208.71554173.davem@davemloft.net>
References: <20061126062939.GM15364@stusta.de>
	<456994ED.9040405@trash.net>
	<20061127085614.GT8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bunk@stusta.de, netdev@vger.kernel.org,
	hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42693
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758823AbWLADwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 22:52:06 -0500
To: tgraf@suug.ch
In-Reply-To: <20061127085614.GT8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 27 Nov 2006 09:56:14 +0100

> * Patrick McHardy <kaber@trash.net> 2006-11-26 14:21
> > One more thing NET_CLS_POLICE affects is CBQ reshape/reclassify
> > handling, reshape_fail seems to be completely unhandled without
> > NET_CLS_POLICE and reclassification looks like it behaves
> > differently with tc actions. I'm not really sure what the
> > reshape_fail stuff is used for, but it looks like we would loose
> > a feature. Jamal?
> 
> Yes, this is the reason why it wasn't removed yet. It always
> occured to me as a mystery why NET_ACT_POLICE didn't depend
> on the same logic inside the qdiscs. That needs to be resolved
> first. Also the compat code for the action variant to handle
> old policer configurations is horrible and should be done in
> a clear way.

Ok, I'll consider this the definitive statement of the
situation.

Adrian, it's not ready to be deleted yet.
