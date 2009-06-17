From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 09:09:54 -0400
Message-ID: <1245244194.4025.21.camel@dogo.mojatatu.com>
References: <20090615111927.GA12316@ff.dom.local>
	 <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local>
	 <200906171201.37727.denys@visp.net.lb>
	 <20090617092626.GA11005@ff.dom.local>
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
Received: from qw-out-2122.google.com ([74.125.92.25]:17717 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759944AbZFQNLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 09:11:13 -0400
Received: by qw-out-2122.google.com with SMTP id 5so153043qwd.37
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2009 06:11:15 -0700 (PDT)
In-Reply-To: <20090617092626.GA11005@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-17 at 09:26 +0000, Jarek Poplawski wrote:
> On Wed, Jun 17, 2009 at 12:01:37PM +0300, Denys Fedoryschenko wrote:
> > On Wednesday 17 June 2009 09:28:46 Jarek Poplawski wrote:
> > 
> > > >
> > > > I confirm I can't get 'action ipt -j MARK' working on debian lenny
> > > > (stable) with distro's iptables/tc. I'm not able to compile tc from
> > > > vanilla sources properly either - configure fails 3 IPT tests. (I
> > > > admit I can miss setting some (undocumented?) config variables.) So,
> > > > with or without debian, IMHO iproute2 needs some updates for iptables
> > > > 1.4.2, 1.4.3, and maybe even 1.4.4 now.
> > >
> > > OOPS! I _can_ configure it for 1.4.2 yet (so it's only about >= 1.4.3).
> > >

Something like that.
It works fine with iptables 1.4.2 for Lenny on my laptop. 
It should work fine for the release after Lenny for 1.4.3 once
the debian maintainers pick up the latest iproute2.
For other Distros: it should work fine if they have iptables 1.4.2/3.
iptables 1.4.4 is not mainstream; i need to add a new test to detect
it once it is mainstream (actually i could do it before it becomes
mainstream and still make it backwards compatible).
I contributed about 10 patches to iptables to try and make sure it
doesnt break again ;-> Hopefully my efforts will be rewarded
(or as the saying goes perhaps "no good deeds go unpunished");->
I have confidence the iptables people are more aware of the API
breakages now than before - so very low probability it will break
post iptables 1.4.4.
For versions lower than iptables 1.4.1 I think i will give up instead of
making it compatible all the way back there.
I use debian exclusively (and these days all my machines are lenny) so
those are the only machines i test on.

> > I check that, and found again many small changes in iptables, that screwed ipt 
> > action in iproute2.
> > 
> > I really think it doesn't worth to put too much efforts fixing it, with each 
> > new release iptables. I switch to other way of "tagging" packets, skbedit, 
> > and it seems it is also faster.
> 
> If it were only about -j MARK you're 100% right. Other targets could
> be harder to replace - if they work of course ;-) Of course it's all
> up to Jamal, but on the other hand I'm really confused debian stable
> (or even testing) maintains such a broken state without any notice
> or simply disabling it to save people's time.
> 

It should work with others as well - if it doesnt theres a bug
somewhere. I dont have time this week - but if theres a script that is
supposed to work that doesnt work, please send it to me and i will look
into it.

cheers,
jamal


