From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: ERR_PTR pattern in phylib
Date: Thu, 2 Sep 2010 16:20:34 +0100 (BST)
Message-ID: <alpine.LFD.2.00.1009021617500.410@eddie.linux-mips.org>
References: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:34100 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755661Ab0IBPUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 11:20:35 -0400
Received: from localhost.localdomain ([127.0.0.1]:49015 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1491020Ab0IBPUe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 17:20:34 +0200
In-Reply-To: <AANLkTimjVZTNeLdm4qptU1MqREODLASdGGanUyxqxfub@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Sep 2010, Grant Likely wrote:

> I've been looking at the phylib code, and specifically at the use of
> the ERR_PTR() pattern.  I'm personally not a big fan of ERR_PTR()
> because the compiler cannot type check the result and it runs
> completely counter to the pattern "if (!ptr)" than is common for
> testing a pointer return value.

 Arguably using a union here would make things cleaner and any reasonable 
ABI will place small unions used as arguments or return values in 
registers, but I'm not sure if the cost of the rewrite is worth the 
benefit.  Probably not, but feel free to propose a change.

  Maciej
