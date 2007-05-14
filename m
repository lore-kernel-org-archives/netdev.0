From: jamal <hadi@cyberus.ca>
Subject: Re: [LAST CALL] [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Mon, 14 May 2007 08:41:38 -0400
Message-ID: <1179146498.15622.66.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost>
	 <1179066518.15622.60.camel@localhost>  <46483C8C.5040403@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:51503 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbXENMlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 08:41:42 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1559505wxd
        for <netdev@vger.kernel.org>; Mon, 14 May 2007 05:41:41 -0700 (PDT)
In-Reply-To: <46483C8C.5040403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-14-05 at 12:40 +0200, Patrick McHardy wrote:

> Two final suggestions, sorry for not mentioning this earlier.

np

> > +			printk(KERN_DEBUG
> > +			       "Dead loop on netdevice %s, fix it urgently!\n",
> > +			       dev->name);
> 
> > +	if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
> > +		printk(KERN_DEBUG " BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);
> 
> 
> For both of these KERN_WARNING or above 

I will make them KERN_WARNING ..

> seems to make sense so
> the messages don't end up in some debug log. Please also fix
> whitespace 

What whitespace issue?

> and line length for the second printk if you're
> going to change this :)

I will fix the length of the second one.

Thanks Patrick.

cheers,
jamal

