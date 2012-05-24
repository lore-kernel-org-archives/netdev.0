From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] tcp: Fast/early SYN handling to mitigate SYN floods
Date: Thu, 24 May 2012 19:27:26 +0200
Message-ID: <1337880446.2655.2.camel@edumazet-glaptop>
References: <1337864467.13491.15.camel@localhost>
	 <4FBE3709.6070806@uclouvain.be> <1337871077.3140.12.camel@edumazet-glaptop>
	 <1337880065.2388.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be, David Miller <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57886 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab2EXR1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 13:27:31 -0400
Received: by eeit10 with SMTP id t10so8451eei.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 10:27:30 -0700 (PDT)
In-Reply-To: <1337880065.2388.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 19:21 +0200, Jesper Dangaard Brouer wrote:

> Sorry, don't remember.

http://kerneltrap.org/mailarchive/linux-netdev/2010/4/19/6274993

> Sounds really promising, especially coming from the network-ninja :-)

;)

> Yes, this is more an emergency mode.
> 
> I was thinking of only handling the SYN cookie case in parallel.
> That should be easier locking wise, right.
> 
> I'm also considering writing a netfilter/iptables syn-cookie module, as
> this would allow people to use it in combination with IPset, to e.g
> create a whitelist feature of known-good-hosts (which have completed the
> TCP handshake). But it would be nicer if the base kernel was just fast
> enough to handle these SYN floods.
> 

Indeed, I believe I can make this happen eventually in a short term.
