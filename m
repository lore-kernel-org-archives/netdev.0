From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/3 v3] pkt_sched: sch_htb: Clean L2T()
Date: Wed, 03 Dec 2008 21:17:09 -0800 (PST)
Message-ID: <20081203.211709.137367864.davem@davemloft.net>
References: <20081203075433.GA7137@ff.dom.local>
	<20081203.002046.153795689.davem@davemloft.net>
	<20081203085006.GA15262@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754456AbYLDFRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 00:17:08 -0500
In-Reply-To: <20081203085006.GA15262@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 3 Dec 2008 08:50:06 +0000

> pkt_sched: sch_htb: Remove L2T()
> 
> L2T() is currently used only in one place (and has one spurious
> parameter, btw), so let's: 'get rid of L2T completely, and just
> use "qdisc_l2t(rate, size)" directly.' - quote & feedback from
> David S. Miller.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
