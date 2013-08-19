From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Mon, 19 Aug 2013 11:10:00 -0700
Message-ID: <1376935800.4226.71.camel@edumazet-glaptop>
References: <1376870425.4226.25.camel@edumazet-glaptop>
	 <1376870592.4226.27.camel@edumazet-glaptop> <5211DAA6.1070302@fatooh.org>
	 <20130819123314.GC3583@cpaasch-mac>
	 <1376918657.4226.59.camel@edumazet-glaptop>
	 <20130819134919.GF3583@cpaasch-mac>
	 <1376920685.4226.61.camel@edumazet-glaptop>
	 <20130819143509.GA31320@linuxace.com> <20130819153328.GH3583@cpaasch-mac>
	 <1376928031.4226.66.camel@edumazet-glaptop>
	 <20130819171519.GA4008@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>,
	Corey Hickey <bugfood-ml@fatooh.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:53467 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab3HSSKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 14:10:03 -0400
In-Reply-To: <20130819171519.GA4008@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-19 at 19:15 +0200, Christoph Paasch wrote:

> 
> Will send it soon. Have to rebase on net-next,... :)
> (it's several months ago that I did this)

No hurry.

This is a very unlikely problem anyway.

Trace taken on a random Google server :

TcpExtTCPSACKDiscard 44666
TcpExtTCPSACKReneging 173593
TcpExtTCPSACKReorder 1331306
TcpExtTCPSackFailures 791292
TcpExtTCPSackMerged 261702691
TcpExtTCPSackRecovery 57267494
TcpExtTCPSackRecoveryFail 2008511
TcpExtTCPSackShiftFallback 841017416
TcpExtTCPSackShifted 619337144
...
TcpOutSegs 42215528084
TcpRetransSegs 441868477
