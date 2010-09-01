From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin
 properly in init_vf()
Date: Wed, 01 Sep 2010 14:30:38 -0700 (PDT)
Message-ID: <20100901.143038.170100274.davem@davemloft.net>
References: <cover.1283197803.git.soltys@ziu.info>
	<8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, denys@visp.net.lb, netdev@vger.kernel.org
To: soltys@ziu.info
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752659Ab0IAVaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:30:22 -0400
In-Reply-To: <8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Soltys <soltys@ziu.info>
Date: Mon, 30 Aug 2010 23:34:10 +0200

> This patch fixes init_vf() function, so on each new backlog period parent's
> cl_cfmin is properly updated (including further propgation towards the root),
> even if the activated leaf has no upperlimit curve defined.
> 
> Signed-off-by: Michal Soltys <soltys@ziu.info>

Applied, thanks.
