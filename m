From: Andi Kleen <andi@firstfloor.org>
Subject: Re: possible bug in tcp_probe
Date: Tue, 13 Nov 2007 14:28:08 +0100
Message-ID: <p73ir46z34n.fsf@bingen.suse.de>
References: <20071113112615.GA7491@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41272 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbXKMN2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 08:28:09 -0500
In-Reply-To: <20071113112615.GA7491@nuim.ie> (Gavin McCullagh's message of "Tue\, 13 Nov 2007 11\:26\:15 +0000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gavin McCullagh <Gavin.McCullagh@nuim.ie> writes:

> I'm using linux v2.6.22.6 and tcp_probe with a couple of small
> modifications[1]. 
>
> Even with moderately large numbers of flows (16 on the one machine) and
> increasingly as I monitor more flows than that, I get strange overflow
> problems such as this one:

You probably just need to increase the buffer (bufsize option to the 
module or tcp_probe.bufsize if compiled in) 

In general I think tcp_probe was always more intended a demo of how kprobes
could be used than a real production tool (with no offense to sch) 

-Andi

