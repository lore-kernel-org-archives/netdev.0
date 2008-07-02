From: David Miller <davem@davemloft.net>
Subject: Re: [RFC]: net-sched 00/05: dynamically sized class hashes
Date: Tue, 01 Jul 2008 19:50:50 -0700 (PDT)
Message-ID: <20080701.195050.177373433.davem@davemloft.net>
References: <20080701143410.26309.45560.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758273AbYGBCut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 22:50:49 -0400
In-Reply-To: <20080701143410.26309.45560.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  1 Jul 2008 16:34:11 +0200 (MEST)

> These patches add support for dynamically sized class hash tables
> to remove a major bottleneck in qdisc filters with many classes
> when filters are not bound to classes and convert CBQ, HTB and HFSC
> to use them.
> 
> Only RFC at this point because they haven't been tested thoroughly yet
> and depend on the filter destruction fixes I sent this morning, but any
> review (especially of 4/5, the htb_delete changes) is welcome.

These patches look fine to me.

I haven't investigated the correctness of the details of patch
4 yet, sorry :-)  Maybe someone else will be able to.

