From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange Panic (Deadlock)
Date: Tue, 25 Dec 2007 15:49:40 +0100
Message-ID: <20071225144940.GA2998@ami.dom.local>
References: <476FCC41.8070202@bigtelecom.ru> <20071224211819.e1ebeicf0ggoo08s@mail.bigtelecom.ru> <47701542.9010806@gmail.com> <4770C956.5040409@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:21726 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbXLYOrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 09:47:46 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1311341ugc.16
        for <netdev@vger.kernel.org>; Tue, 25 Dec 2007 06:47:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4770C956.5040409@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 25, 2007 at 12:11:50PM +0300, Badalian Vyacheslav wrote:
...
> ok. i will add it to bugtracker, but bug process in gentoo and in
> vanilla kernel.
> I send to netdev mail list becouse i think that bug depend to TC or
> IPTABLES functional.
> I have 4 machine. All platforms different.   All machine do 1 time in
> hour rebuild TC and IPTABLES rules.
> After it do
> echo START >> log.txt
> iptables-restore < xxx.txt
> tc qdisc del dev eth0 root
> tc qdisc del dev eth1 root
> tc -b new_rules.txt
> echo END >> log.txt
> 
> and its all that its doing.
> Bug always be between START and END
> All machines have above 300mbs traffic.
> I try turn off rebuilding rules on 1 PC and it work 3 week without reboot!
> 
> I think that situation ask that problem depends to network. If its
> mistake - sorry please.
> 

Yes, this description seems to point at network, but since the bug
triggers in timer.c ...we could try to share this work with somebody
(or even blame them 100% if they are not clever enough...)?!
 
I think there were similar things reported especially around HTB, but
it seems there were problems with later debugging. I'll try to think
about it, but if there are some more logs or details, it should be
helpful.

BTW: you've written there is a need to go and reboot this each time:
did you try something like drivers/char/watchdog/softdog.c?

Regards,
Jarek P.
