From: jamal <hadi@cyberus.ca>
Subject: Re: traffic shaping with NAT: IFB as IMQ replacement?
Date: Thu, 29 Mar 2007 12:11:56 -0400
Message-ID: <1175184716.4881.30.camel@localhost>
References: <m27it09n5w.fsf@quark.karme-net.hirschau>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuximq@yahoogroups.com
To: Jens Thiele <karme@berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:16341 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932189AbXC2QMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 12:12:00 -0400
Received: by wx-out-0506.google.com with SMTP id h31so218949wxd
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 09:11:59 -0700 (PDT)
In-Reply-To: <m27it09n5w.fsf@quark.karme-net.hirschau>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-28-03 at 18:54 +0200, Jens Thiele wrote:
> Hello,
> 
> Sorry for the many Ccs, but I hope to reach all parties involved.
> I want to do traffic shaping with NAT and I wanted to do it with IFB
> instead of IMQ [1]. I tried a lot of things but now I am stuck (and
> maybe confused).
> 
> The setup:
>                eth0             eth1
> WAN/(Internet) <-> Linux Router <-> LAN
> 
> Linux router:
> - does NAT for the LANs
> - runs local processes communicating with the WAN/Internet
> 

I understand this requirement; unfortunately when i polled for features
majority of people who emailed back were asking for the other things.
I have changed my opinion a little since last time because the
netfilter/contracking code now does netlink. I believe this could all be
achieved in user space. Infact i have started writting some code - the
problem is my time has become intermittent.
If i can get someone who can work with me to complete the work, I will
be more than happy to get that last bastion of IMQ done.
So if you are a fireman willing to be a hero (I guess all firemen want
to be heroes, why else would they be firemen?) email me privately and we
can get this done.

cheers,
jamal

PS:- i have removed lartc from the list because it bounces my emails and
i refuse to subscribe.

