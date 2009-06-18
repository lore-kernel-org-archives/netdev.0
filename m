From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Thu, 18 Jun 2009 20:39:58 +0200
Message-ID: <20090618183958.GA2766@ami.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local> <200906171201.37727.denys@visp.net.lb> <20090617092626.GA11005@ff.dom.local> <1245244194.4025.21.camel@dogo.mojatatu.com> <20090617194318.GA2747@ami.dom.local> <1245331181.3876.11.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:64064 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752541AbZFRSk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 14:40:26 -0400
Received: by bwz9 with SMTP id 9so1300475bwz.37
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 11:40:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1245331181.3876.11.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2009 at 09:19:41AM -0400, jamal wrote:
> On Wed, 2009-06-17 at 21:43 +0200, Jarek Poplawski wrote:
> 
> > You mean Lenny with not Lenny's iproute2, I guess. Does 'works fine'
> > include 'action ipt -j LOG'? Anyway, let's say you're right here, and
> > it's "Lenny's" problem.
> 
> I havent tried ipt LOG; Lenny cannot be updated anymore AFAIK; Andreas
> may be able to give you a better answer on their strict process.

I think I understand this strict process; I don't understand why with
this strict process there is buggy software maintained without any
notice (if it wasn't spotted before going stable, which is hard to
believe).

> 
> > Why do you think so? I've tried it with current (git) iproute2 and
> > iptables 1.4.3.2 (Debian include files are eq. to vanilla), and here
> > is the configure output:
> 
> I can almost bet you that you are linking to the wrong iptables library.
> Did you install the new iptables yourself? Lenny certainly doesnt run
> iptables 1.4.3.2. Note:
> It is not just the headers - you need to point to the right lib. It is
> a big mess.

You mentioned: 
> > It should work fine for the release after Lenny for 1.4.3 once
> > the debian maintainers pick up the latest iproute2.

...and I use this release after Lenny named Squeeze (or Testing),
with iptables 1.4.3.2, plus fresh iproute2 from git. (I guess, btw.
this is a process used by many admins.) OK, I'd gladly point to
the right lib, but where is it described? And why similar process
on Lenny with 1.4.2 and git iproute2 doesn't need such steps. So,
again: maybe it works, but if I didn't manage, Debian didn't manage,
and even Denys (who, AFAICR, can compile even Gentoo! ;-) mentioned
he gave up ipt - then it looks like at least a bit too complex...

> > 
> > After this I get tc compiled, but it gives misleading error messages
> > later (just like distro's tc).
> 
> Refer to above.
> 
> > > For other Distros: it should work fine if they have iptables 1.4.2/3.
> > 
> > The latest official version 1.4.3.2 (until today) doesn't work fine
> > for Debian & me (maybe we're special...).
> > 
> 
> Are you running something other than lenny?
>  dogo:~# iptables -V
> iptables v1.4.2

Yes, I mentionned it at the beginning:
> But... I'm neither able to configure/compile it with the current
> iproute2/iptables, nor test it with distro's builds (Debian testing).

info@ami:~$ iptables -V
iptables v1.4.3.2

> > I don't understand why you're defending those ugly destroyers of your
> > outstanding work?! (Did they threaten you? Don't worry - they're far
> > away in Australia... ;-)
> > 
> 
> Well, I have seen genuine effort to try and fix things ;->
> 
> > Just similarly to Pawel:
> > tc qdisc add dev lo root handle 1: htb
> > tc filter add dev lo parent 1: proto ip pref 5 u32 match u32 0 0 action ipt -j LOG
> 
> Thanks.
> I will make time and chase this.

I wish you that nobody dare brake it again!

Cheers,
Jarek P.
