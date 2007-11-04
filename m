From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Sun, 04 Nov 2007 13:56:21 -0800 (PST)
Message-ID: <20071104.135621.48992864.davem@davemloft.net>
References: <20071103.162337.83099185.davem@davemloft.net>
	<472DAD90.4050709@cosmosbay.com>
	<200711041326.38380.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com,
	jarkao2@o2.pl
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753082AbXKDV4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 16:56:21 -0500
In-Reply-To: <200711041326.38380.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sun, 4 Nov 2007 13:26:38 +0100

> 
> > But I suspect distributions kernels enable CONFIG_HOTPLUG_CPU so 
> > num_possible_cpus() will be NR_CPUS.
> 
> Nope, on x86 num_possible_cpus() is derived from BIOS tables these days.

And similarly on SPARC64 is will be set based upon the
physical capabilities of the system.

This makes a huge different as we have to set NR_CPUS to 4096
in order to handle the cpu numbering of some UltraSPARC-IV
machines.
