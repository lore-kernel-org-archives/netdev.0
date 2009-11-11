From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't go back.
Date: Wed, 11 Nov 2009 04:03:52 -0500
Message-ID: <1257930232.4685.20.camel@bigi>
References: <4AF7B9F4.6010507@gmail.com> <1257751376.8009.2.camel@bigi>
	 <412e6f7f0911090031j16ab9c73o47f4d4d3ffd9be3a@mail.gmail.com>
	 <1257764086.6246.1.camel@bigi>
	 <412e6f7f0911090433j2b270663ycdf277110fbc6bac@mail.gmail.com>
	 <1257838834.3647.4.camel@bigi>
	 <412e6f7f0911100050k39920adfl1ab70e345269833a@mail.gmail.com>
	 <1257927097.4685.4.camel@bigi>
	 <412e6f7f0911110044i22c28ab6pa3a3691c014e76a8@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:49787 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbZKKJDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 04:03:43 -0500
Received: by ywh40 with SMTP id 40so772871ywh.33
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 01:03:48 -0800 (PST)
In-Reply-To: <412e6f7f0911110044i22c28ab6pa3a3691c014e76a8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-11 at 16:44 +0800, Changli Gao wrote:

> The current kernel and iproute2 support ingress in another way, that
> is attaching the filter to the corresponding ingress qdisc. refter to
> http://www.linuxfoundation.org/en/Net:IFB . 

that looks like something i wrote ;->

> The loops is avoided in
> netif_receive_skb() and with TTL mechanism. 
> Do you have more
> documentation or examples about socket redirect? Sorry, I don't know
> what it is used to do. Is it sth. like ipt_REDIRECT?

I open a socket and I install a filter to mirror or redirect to this
socket. It is possible to do it today if you use tun device; thats
why i have never been motivated to do it.

cheers,
jamal

