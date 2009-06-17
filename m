From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 12:01:37 +0300
Message-ID: <200906171201.37727.denys@visp.net.lb>
References: <20090615111927.GA12316@ff.dom.local> <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>,
	=?utf-8?q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:53843 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbZFQJBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 05:01:32 -0400
In-Reply-To: <20090617062846.GA9764@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 June 2009 09:28:46 Jarek Poplawski wrote:

> >
> > I confirm I can't get 'action ipt -j MARK' working on debian lenny
> > (stable) with distro's iptables/tc. I'm not able to compile tc from
> > vanilla sources properly either - configure fails 3 IPT tests. (I
> > admit I can miss setting some (undocumented?) config variables.) So,
> > with or without debian, IMHO iproute2 needs some updates for iptables
> > 1.4.2, 1.4.3, and maybe even 1.4.4 now.
>
> OOPS! I _can_ configure it for 1.4.2 yet (so it's only about >= 1.4.3).
>
I check that, and found again many small changes in iptables, that screwed ipt 
action in iproute2.

I really think it doesn't worth to put too much efforts fixing it, with each 
new release iptables. I switch to other way of "tagging" packets, skbedit, 
and it seems it is also faster.
