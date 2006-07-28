From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Fri, 28 Jul 2006 08:45:37 -0400
Message-ID: <1154090737.5165.69.camel@jzny2>
References: <20060728014528.GB29313@innerghost.net>
	 <20060727.192743.39159331.davem@davemloft.net>
	 <20060728031322.GE29313@innerghost.net>
	 <20060727.202044.85689055.davem@davemloft.net>
	 <20060728033132.GF29313@innerghost.net>
	 <20060727210738.36f33436@localhost.localdomain>
	 <20060728083433.GG29313@innerghost.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:24999 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750922AbWG1Mpm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 08:45:42 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1G6Riq-0004e6-GQ
	for netdev@vger.kernel.org; Fri, 28 Jul 2006 08:45:44 -0400
To: Hugo Santos <hsantos@av.it.pt>
In-Reply-To: <20060728083433.GG29313@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-28-07 at 09:34 +0100, Hugo Santos wrote:

> > 2. What if user process dies? or gets overwhelmed?
> >    One of the assumptions of the any well designed kernel is that the system should never
> >    hang because some user application died or waited for ever.
> 
>    Of course that this is a real problem. However, if the control daemon
>  dies the kernel won't die. Depending on the implementation -- you might
>  temporarily get out of addresses, if the addresses are flushed when the
>  control daemon dies, etc. But, just like a routing daemon is critical
>  to a router, this control application would also be critical to the
>  host's connectivity. And if it dies, it needs to be restarted. The
>  application might be itself complex, but in the end we moved this
>  complexity away from the kernel.
> 

Hugo,

The biggest challenge you will face is the view that people hate daemons
- mostly from a usability perspective (is the gist of the arguements i
have seen) but also because of concerns such as the one Stephen mentions
above. 
I hold the same views as you do on the separation of control from the
datapath and to respond to Stephens assertion on well designed kernel
above: It is good kernel abstraction to separate policy management from
mechanisms.

The certificate issue only validates further this pov: that control
tends to be feature-rich, swiss-army knife i.e more moving target than
datapath. Such things typically belong to user-space.
I have also seen talk of secure ARP; i wonder if there may be
certificates involved there as well? If you look at the archives on
netdev you may notice such discussions. Summary: I violently agree with
you and i think if you address the "daemon" concerns, you will get other
folks to agree as well.

cheers,
jamal




