From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 09:26:26 +0000
Message-ID: <20090617092626.GA11005@ff.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local> <200906171201.37727.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f226.google.com ([209.85.218.226]:43987 "EHLO
	mail-bw0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbZFQJ0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 05:26:30 -0400
Received: by bwz26 with SMTP id 26so164946bwz.7
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 02:26:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200906171201.37727.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 12:01:37PM +0300, Denys Fedoryschenko wrote:
> On Wednesday 17 June 2009 09:28:46 Jarek Poplawski wrote:
> 
> > >
> > > I confirm I can't get 'action ipt -j MARK' working on debian lenny
> > > (stable) with distro's iptables/tc. I'm not able to compile tc from
> > > vanilla sources properly either - configure fails 3 IPT tests. (I
> > > admit I can miss setting some (undocumented?) config variables.) So,
> > > with or without debian, IMHO iproute2 needs some updates for iptables
> > > 1.4.2, 1.4.3, and maybe even 1.4.4 now.
> >
> > OOPS! I _can_ configure it for 1.4.2 yet (so it's only about >= 1.4.3).
> >
> I check that, and found again many small changes in iptables, that screwed ipt 
> action in iproute2.
> 
> I really think it doesn't worth to put too much efforts fixing it, with each 
> new release iptables. I switch to other way of "tagging" packets, skbedit, 
> and it seems it is also faster.

If it were only about -j MARK you're 100% right. Other targets could
be harder to replace - if they work of course ;-) Of course it's all
up to Jamal, but on the other hand I'm really confused debian stable
(or even testing) maintains such a broken state without any notice
or simply disabling it to save people's time.

Jarek P.
