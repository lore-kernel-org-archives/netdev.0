From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: ERR_PTR pattern in phylib
Date: Thu, 2 Sep 2010 17:43:35 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1009021735320.410@eddie.linux-mips.org>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>        <alpine.LFD.2.00.1009021617500.410@eddie.linux-mips.org> <20100902.093451.189703514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: grant.likely@secretlab.ca, afleming@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:50072 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672Ab0IBQng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:43:36 -0400
Received: from localhost.localdomain ([127.0.0.1]:33471 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491020Ab0IBQnf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 18:43:35 +0200
In-Reply-To: <20100902.093451.189703514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Sep 2010, David Miller wrote:

> >  Arguably using a union here would make things cleaner and any reasonable 
> > ABI will place small unions used as arguments or return values in 
> > registers, but I'm not sure if the cost of the rewrite is worth the 
> 
> Well, sparc 32-bit's ABI for one is "not reasonable" and these return
> values will always get stack slots and passed back by reference.

 So that makes it two -- together with MIPS o32. ;)  Still used by 
everybody concerned as contraptions tend to stick. :/  That doesn't make 
it reasonable though.  Nor me to push the union approach -- that's an 
elegant approach that would probably give us less than take in return.

  Maciej
