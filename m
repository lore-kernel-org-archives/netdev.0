From: David Miller <davem@davemloft.net>
Subject: Re: net-sched 07/06: sch_htb: remove write-only qdisc filter_cnt
Date: Sat, 05 Jul 2008 23:28:16 -0700 (PDT)
Message-ID: <20080705.232816.53924758.davem@davemloft.net>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
	<486E1573.8040303@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devik@cdi.cz, jarkao2@gmail.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751479AbYGFG2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 02:28:16 -0400
In-Reply-To: <486E1573.8040303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 Jul 2008 14:20:03 +0200

>     net-sched: sch_htb: remove write-only qdisc filter_cnt
>     
>     The filter_cnt is supposed to count filter references to a class.
>     Since the qdisc can't be the target of a filter, it doesn't need
>     a filter_cnt. In fact the counter is never decreased since cls_api
>     considers a return value of zero a failure and doesn't unbind again.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Also applied, thanks Patrick.
