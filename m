From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 4 Nov 2007 13:26:38 +0100
Message-ID: <200711041326.38380.ak@suse.de>
References: <4729A774.9030409@cosmosbay.com> <20071103.162337.83099185.davem@davemloft.net> <472DAD90.4050709@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	acme@redhat.com, Jarek Poplawski <jarkao2@o2.pl>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38706 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754100AbXKDM0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 07:26:42 -0500
In-Reply-To: <472DAD90.4050709@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> But I suspect distributions kernels enable CONFIG_HOTPLUG_CPU so 
> num_possible_cpus() will be NR_CPUS.

Nope, on x86 num_possible_cpus() is derived from BIOS tables these days.

-Andi
