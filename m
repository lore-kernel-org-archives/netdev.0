From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: revised locking for x_tables
Date: Tue, 28 Apr 2009 09:55:32 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904280954500.22156@localhost.localdomain>
References: <20090428135219.GA28513@Krystal> <20090428.073759.78537345.davem@davemloft.net> <20090428144920.GA28942@Krystal> <20090428.080031.14741305.davem@davemloft.net> <20090428092411.5331c4a1@nehalam>
 <alpine.LFD.2.00.0904280931360.22156@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, mathieu.desnoyers@polymtl.ca,
	mingo@elte.hu, dada1@cosmosbay.com, zbr@ioremap.net,
	peterz@infradead.org, jarkao2@gmail.com, paulus@samba.org,
	paulmck@linux.vnet.ibm.com, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33169 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750857AbZD1RIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 13:08:04 -0400
In-Reply-To: <alpine.LFD.2.00.0904280931360.22156@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 28 Apr 2009, Linus Torvalds wrote:
>
> Ack. 
> 
> It could do with the update from Eric about how non-current CPU writelocks 
> only require preemp-disable around get_counters() (and then the 
> local_bh_disable() only around the current-CPU case).

Btw, regardless, that's an incremental improvement, and does not negate 
the "Ack" part.

			Linus
