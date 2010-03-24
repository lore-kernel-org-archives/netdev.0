From: jamal <hadi@cyberus.ca>
Subject: Re: [patch] af_key: return error if pfkey_xfrm_policy2msg_prep()
 fails
Date: Wed, 24 Mar 2010 12:39:50 -0400
Message-ID: <1269448790.4089.34.camel@bigi>
References: <20100324114700.GB21571@bicker> <1269438383.4089.15.camel@bigi>
	 <20100324161921.GA5069@bicker>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:52920 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab0CXQj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 12:39:56 -0400
In-Reply-To: <20100324161921.GA5069@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-24 at 19:19 +0300, Dan Carpenter wrote:
> On Wed, Mar 24, 2010 at 09:46:23AM -0400, jamal wrote:
> > On Wed, 2010-03-24 at 14:47 +0300, Dan Carpenter wrote:
> > > The original code saved the error value but just returned 0 in the end.
> > 
> > Looks reasonable and harmless. 
> > If you have time - can you try this one test with your patch and see if
> > any strange message shows up when you delete? add a policy on window1,
> > on window2 run ip xfrm mon and then back on window1 delete it and watch
> > the event on window2
> > 
> > ----
> > window2: ip xfrm mon
> > 
> > window1, add:
> > ip xfrm policy add src 172.16.2.0/24 dst 172.16.1.0/24 \
> >         dir fwd ptype main \
> >         tmpl src 192.168.2.100 dst 192.168.1.100 \
> >         proto esp mode tunnel
> > 
> > 
> > window1, delete:
> > ip xfrm pol del src 172.16.2.0/24 dst 172.16.1.0/24 dir fwd
> > ----
> 
> Sure.  I tried that and it looks OK.  
> 

I am really sorry - your patch is pfkey path and the example i gave you
is xfrm based;-< I worry too much, so never mind - the change seems
harmless enough:
Acked-by: Jamal Hadi Salim <hadi@mojatatu.com>


cheers,
jamal

