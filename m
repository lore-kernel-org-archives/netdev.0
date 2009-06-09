From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pkt_sched: Use PSCHED_SHIFT in PSCHED time
 conversion
Date: Tue, 09 Jun 2009 05:21:24 -0700 (PDT)
Message-ID: <20090609.052124.23906164.davem@davemloft.net>
References: <20090609080500.GA5237@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, vexwek@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, devik@cdi.cz, dada1@cosmosbay.com,
	hazard@francoudi.com, slavon@bigtelecom.ru
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755504AbZFIMVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:21:22 -0400
In-Reply-To: <20090609080500.GA5237@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 9 Jun 2009 08:05:00 +0000

> Use PSCHED_SHIFT constant instead of '10' in PSCHED_US2NS() and
> PSCHED_NS2US() macros to enable changing this value later.
> 
> Additionally use PSCHED_SHIFT in sch_hfsc SM_SHIFT and ISM_SHIFT
> definitions. This part of the patch is based on feedback from
> Patrick McHardy <kaber@trash.net>.
> 
> Reported-by: Antonio Almeida <vexwek@gmail.com>
> Tested-by: Antonio Almeida <vexwek@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied.
