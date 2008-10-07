From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 10:54:42 +0200
Message-ID: <m37i8k3hv1.fsf@ursa.amorsen.dk>
References: <20081006185026.GA10383@minyard.local>
	<48EA8197.6080502@cosmosbay.com>
	<20081006.144002.56418911.davem@davemloft.net>
	<48EAF29D.8050203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([217.195.186.3]:56414 "EHLO
	gate1.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYJGJ2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 05:28:39 -0400
In-Reply-To: <48EAF29D.8050203@cosmosbay.com> (Eric Dumazet's message of "Tue\, 07 Oct 2008 07\:24\:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> writes:

> Most UDP sockets are setup for long periods (RTP trafic), or if an application really
> wants to {open/send or receive one UDP frame/close} many sockets, it already hits
> RCU handling of its file structures and should not be slowed down that much.
>
> By 'long period' I mean thousand of packets sent/received by each RTP session, being
> voice (50 packets/second) or even worse video...

Does DNS with port randomization need short lived sockets?


/Benny

