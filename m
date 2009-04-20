From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with IRQ affinity)
Date: Mon, 20 Apr 2009 23:44:10 +0400
Message-ID: <20090420194410.GA26909@ioremap.net>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com> <alpine.DEB.1.10.0904201305360.1585@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:59830 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751356AbZDTTo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 15:44:28 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904201305360.1585@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Mon, Apr 20, 2009 at 01:29:54PM -0400, Christoph Lameter (cl@linux.com) wrote:
> > I only took traces on receivers to rule out different coalescing delays
> > of NIC that could depend on firmware or version
> 
> Hmmm... Okay there could be a firmware influence....

Can you replace the driver in one or another kernel?
Can those be scheduler (I said wrong words I know) iteractions? Maybe
test with sched_rt priority?

-- 
	Evgeniy Polyakov
