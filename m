From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Mon, 15 Jun 2009 16:52:22 +0200
Message-ID: <20090615145222.GA2767@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f206.google.com ([209.85.220.206]:63798 "EHLO
	mail-fx0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756958AbZFOOwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 10:52:38 -0400
Received: by fxm2 with SMTP id 2so348772fxm.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 07:52:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1245072728.3948.14.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 09:32:08AM -0400, jamal wrote:
> On Mon, 2009-06-15 at 11:19 +0000, Jarek Poplawski wrote:
> 
> > > This is only a sample but is not working
> 
> It does seem to be working!
> How did you reach conclusion it wasnt working?
> 
> > >         Action statistics:
> > >         Sent 42351 bytes 110 pkt (dropped 0, overlimits 32 requeues 0)
> > >         rate 0bit 0pps backlog 0b 0p requeues 0
> 
> 32 packets hit the policer - double check your parameters please to make
> sure they are correct.

Actually, I wonder if these "dropped 0" are OK here if we expect
dropping.

> 
> > According to iproute2/doc/actions/actions_general mangle targets
> > should work; and you could also try (if it doesn't work then probably
> > it can't be used...;-)
> 
> They should all be usable. If something crashes, there is a bug
> somewhere.
> 
> > But... I'm neither able to configure/compile it with the current
> > iproute2/iptables, nor test it with distro's builds (Debian testing).
> > After some checking I found iproute2 needs updating, because iptables
> > changes API (xtables.h) virtually with every new version, so I don't
> > even blame the ipt author or distro maintainer.
> > 
> 
> We are hopefully getting stable there. Anything on debian lenny
> should be working with iptables 1.4.3; i expect at most "one last
> change" (famous last words) to break backward compat as iptables 
> moves from version 1.4.3.

I've tried debian squeeze (testing) with: iptables v1.4.3.2, iproute2
-ss090324, and action ipt -j MARK doesn't work. AFAIK debian lenny
(stable) uses 1.4.2. I've also tried debian rescue probably based on
lenny (with iptables 1.4.2), and it seemed it didn't work yet (I'll
re-check this). When you have something new I'd be glad for Cc.

Thanks more than always Jamal,
Jarek P.
