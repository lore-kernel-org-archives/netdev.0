From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 09:32:08 -0400
Message-ID: <1245072728.3948.14.camel@dogo.mojatatu.com>
References: <20090615111927.GA12316@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:46788 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbZFONd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 09:33:26 -0400
Received: by qyk3 with SMTP id 3so268549qyk.33
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 06:33:27 -0700 (PDT)
In-Reply-To: <20090615111927.GA12316@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:

> > This is only a sample but is not working

It does seem to be working!
How did you reach conclusion it wasnt working?

> >         Action statistics:
> >         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues 0)
> >         rate 0bit 0pps backlog 0b 0p requeues 0

32 packets hit the policer - double check your parameters please to make
sure they are correct.

> According to iproute2/doc/actions/actions_general mangle targets
> should work; and you could also try (if it doesn't work then probably
> it can't be used...;-)

They should all be usable. If something crashes, there is a bug
somewhere.

> But... I'm neither able to configure/compile it with the current
> iproute2/iptables, nor test it with distro's builds (Debian testing).
> After some checking I found iproute2 needs updating, because iptables
> changes API (xtables.h) virtually with every new version, so I don't
> even blame the ipt author or distro maintainer.
> 

We are hopefully getting stable there. Anything on debian lenny
should be working with iptables 1.4.3; i expect at most "one last
change" (famous last words) to break backward compat as iptables 
moves from version 1.4.3.

> I guess, after studying these iproute2 docs examples you should be
> able to do such tricks eg. with mirred and other actions even without
> ipt. Or you could ask authors for more docs...

I have sparse time this week - but i can help with Debian Lenny which
is what my laptop runs with some variable response latency.

> PS: the tc classifier maintainer added to Cc.

Thanks as always Jarek.

cheers,
jamal

