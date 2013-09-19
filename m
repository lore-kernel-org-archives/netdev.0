From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] skge: fix broken driver
Date: Thu, 19 Sep 2013 23:32:18 +0200
Message-ID: <20130919213218.GA31672@electric-eye.fr.zoreil.com>
References: <alpine.LRH.2.02.1309191229480.32035@file01.intranet.prod.int.rdu2.redhat.com>
 <20130919.135628.1201613770803318193.davem@davemloft.net>
 <alpine.LRH.2.02.1309191359300.12162@file01.intranet.prod.int.rdu2.redhat.com>
 <1379614608.2331.0.camel@ThinkPad-X230.localdomain>
 <alpine.LRH.2.02.1309191427420.15640@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Gnatenko <i.gnatenko.brain@gmail.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52258 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3ISVc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 17:32:29 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1309191427420.15640@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikulas Patocka <mpatocka@redhat.com> :
[...]
> I see. My patch is a bit simpler - it doesn't allocate the structure 
> skge_element on the stack.

Both patches don't behave exactly the same wrt pci_unmap_single.

-- 
Ueimor
