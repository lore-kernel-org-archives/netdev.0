From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: Strange Panic (Deadlock)
Date: Tue, 25 Dec 2007 17:38:09 +0200
Message-ID: <20071225152924.M81218@visp.net.lb>
References: <476FCC41.8070202@bigtelecom.ru> <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru> <47701542.9010806@gmail.com> <4770C956.5040409@bigtelecom.ru> <20071225144940.GA2998@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:59234 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbXLYPig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 10:38:36 -0500
In-Reply-To: <20071225144940.GA2998@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably also there is TCO watchdog, if it is Intel motherboard. I am using
also on unreliable machines nmi_watchdog. And also if it is servers, probably
there is IPMI.

Plus it is IMHO important to know lspci -vvv, cat /proc/interrupts, and kernel
config.

Vyacheslav, on my experience i am tried also latest rc kernels on production
machines, it helps sometimes for me, and also it helps alot to kernel
developers. Gentoo kernels not heavily patched in critical parts, but IMHO it
will make debugging difficult, if patch exist in "failed" part.

I am not kernel developer, but can help with watchdogs and etc, and probably
extended debugging. Contact me via ICQ 17962627 or MSN nuclearcat AT
nuclearcat.com, probably i can help somehow to make your setup more reliable.

On Tue, 25 Dec 2007 15:49:40 +0100, Jarek Poplawski wrote
> On Tue, Dec 25, 2007 at 12:11:50PM +0300, Badalian Vyacheslav wrote:
> ....
> > ok. i will add it to bugtracker, but bug process in gentoo and in
> > vanilla kernel.
> > I send to netdev mail list becouse i think that bug depend to TC or
> > IPTABLES functional.
> > I have 4 machine. All platforms different.   All machine do 1 time in
> > hour rebuild TC and IPTABLES rules.
> > After it do
> > echo START >> log.txt
> > iptables-restore < xxx.txt
> > tc qdisc del dev eth0 root
> > tc qdisc del dev eth1 root
> > tc -b new_rules.txt
> > echo END >> log.txt
> > 
> > and its all that its doing.
> > Bug always be between START and END
> > All machines have above 300mbs traffic.
> > I try turn off rebuilding rules on 1 PC and it work 3 week without reboot!
> > 
> > I think that situation ask that problem depends to network. If its
> > mistake - sorry please.
> >
> 
> Yes, this description seems to point at network, but since the bug
> triggers in timer.c ...we could try to share this work with somebody
> (or even blame them 100% if they are not clever enough...)?!
> 
> I think there were similar things reported especially around HTB, but
> it seems there were problems with later debugging. I'll try to think
> about it, but if there are some more logs or details, it should be
> helpful.
> 
> BTW: you've written there is a need to go and reboot this each time:
> did you try something like drivers/char/watchdog/softdog.c?
> 
> Regards,
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

