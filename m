From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Sun, 04 Nov 2007 20:35:08 -0800 (PST)
Message-ID: <20071104.203508.11916143.davem@davemloft.net>
References: <20071104.135621.48992864.davem@davemloft.net>
	<200711050001.03699.ak@suse.de>
	<20071104.202454.216339392.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com,
	jarkao2@o2.pl
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753159AbXKEEfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2007 23:35:08 -0500
In-Reply-To: <20071104.202454.216339392.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 04 Nov 2007 20:24:54 -0800 (PST)

> From: Andi Kleen <ak@suse.de>
> Date: Mon, 5 Nov 2007 00:01:03 +0100
> 
> > If it's for sparse cpu ids -- x86 handles those with an 
> > translation array.
> 
> I would rather not do this, so much assembler code indexes straight
> into the per-cpu arrays.

Also, at current rates, I'll need to be able to support
4096 cpus for real not very long from now :-)
