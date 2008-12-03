From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/3] pkt_sched: sch_htb: Clean L2T()
Date: Tue, 02 Dec 2008 23:25:22 -0800 (PST)
Message-ID: <20081202.232522.108544572.davem@davemloft.net>
References: <20081202085648.GC10412@ff.dom.local>
	<20081203070947.GA5598@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devik@cdi.cz, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753266AbYLCHZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 02:25:22 -0500
In-Reply-To: <20081203070947.GA5598@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 3 Dec 2008 07:09:47 +0000

> L2T() is currently used only in one place, so let's move it closer to
> this place, remove unused cl parameter, and change to a macro.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Jarek, please just kill the macro and expand the calculation inline.
