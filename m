From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action/policer question
Date: Thu, 18 Jun 2009 09:19:41 -0400
Message-ID: <1245331181.3876.11.camel@dogo.mojatatu.com>
References: <20090615111927.GA12316@ff.dom.local>
	 <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local>
	 <200906171201.37727.denys@visp.net.lb>
	 <20090617092626.GA11005@ff.dom.local>
	 <1245244194.4025.21.camel@dogo.mojatatu.com>
	 <20090617194318.GA2747@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryschenko <denys@visp.net.lb>,
	=?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:26729 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbZFRNVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 09:21:02 -0400
Received: by qw-out-2122.google.com with SMTP id 5so576785qwd.37
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 06:21:04 -0700 (PDT)
In-Reply-To: <20090617194318.GA2747@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-17 at 21:43 +0200, Jarek Poplawski wrote:

> You mean Lenny with not Lenny's iproute2, I guess. Does 'works fine'
> include 'action ipt -j LOG'? Anyway, let's say you're right here, and
> it's "Lenny's" problem.

I havent tried ipt LOG; Lenny cannot be updated anymore AFAIK; Andreas
may be able to give you a better answer on their strict process.

> Why do you think so? I've tried it with current (git) iproute2 and
> iptables 1.4.3.2 (Debian include files are eq. to vanilla), and here
> is the configure output:

I can almost bet you that you are linking to the wrong iptables library.
Did you install the new iptables yourself? Lenny certainly doesnt run
iptables 1.4.3.2. Note:
It is not just the headers - you need to point to the right lib. It is
a big mess.

> 
> After this I get tc compiled, but it gives misleading error messages
> later (just like distro's tc).

Refer to above.

> > For other Distros: it should work fine if they have iptables 1.4.2/3.
> 
> The latest official version 1.4.3.2 (until today) doesn't work fine
> for Debian & me (maybe we're special...).
> 

Are you running something other than lenny?
 dogo:~# iptables -V
iptables v1.4.2

> I don't understand why you're defending those ugly destroyers of your
> outstanding work?! (Did they threaten you? Don't worry - they're far
> away in Australia... ;-)
> 

Well, I have seen genuine effort to try and fix things ;->

> Just similarly to Pawel:
> tc qdisc add dev lo root handle 1: htb
> tc filter add dev lo parent 1: proto ip pref 5 u32 match u32 0 0 action ipt -j LOG

Thanks.
I will make time and chase this.

cheers,
jamal

