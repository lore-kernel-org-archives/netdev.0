From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Slow OOM in netif_RX function
Date: Mon, 4 Feb 2008 16:55:26 +0100
Message-ID: <20080204155526.GA7988@one.firstfloor.org>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de> <20080125141204.GA25510@ghostprotocols.net> <47A315DC.3070101@obs.bg> <47A31BBA.8040307@cosmosbay.com> <47A33D02.8050503@obs.bg> <47A72740.9030706@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Ivan Dichev <idichev@obs.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55065 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYBDPUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 10:20:41 -0500
Content-Disposition: inline
In-Reply-To: <47A72740.9030706@obs.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Nothing that looks like a struct net_device. All the dumped leaked slab
> look the same until "45 20 05 d8" (the ascii 'E' on the 3rd line).

45 ... is often the start of an IP header (IPv4, 5*4=20 bytes length)

You could dump them to a file (e.g. using a sial script) and then
look at them with tcpdump or similar to get an idea what kinds 
of packets they are.

-Andi

