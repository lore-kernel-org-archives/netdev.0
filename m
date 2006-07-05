From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/3] [PKT_SCHED]: Fix illegal memory dereferences when dumping actions
Date: Wed, 5 Jul 2006 11:09:33 +0200
Message-ID: <20060705090933.GW14627@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch> <20060704220549.952720000@postel.suug.ch> <44AAFCF6.9000706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47827 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964774AbWGEJJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 05:09:12 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44AAFCF6.9000706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-07-05 01:42
> Thomas Graf wrote:
> > @@ -834,7 +833,7 @@ tc_dump_action(struct sk_buff *skb, stru
> >  	a.ops = a_o;
> >  
> >  	if (a_o->walk == NULL) {
> > -		printk("tc_dump_action: %s !capable of dumping table\n", kind);
> > +		printk("tc_dump_action: %s !capable of dumping table\n", a_o->kind);
> >  		goto rtattr_failure;
> >  	}
> 
> Can't we just get rid of these printks? This seems like a good
> opportunity.

I agree, since this patch is definitely a stable candidate I
wanted it to stay as small as possible.
