From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v2 net-next 2/5] qed/qede: Add VXLAN tunnel slowpath
 configuration support
Date: Thu, 14 Apr 2016 19:52:44 +0000
Message-ID: <SN2PR11MB0094C4E2F13DA03C1E06C99497970@SN2PR11MB0094.namprd11.prod.outlook.com>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
	<1460612313-20323-3-git-send-email-manish.chopra@qlogic.com>
 <20160414.152601.1422370571524886675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>,
	Manish Chopra <manish.chopra@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0130.outbound.protection.outlook.com ([157.56.111.130]:18400
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751306AbcDNTwr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:52:47 -0400
In-Reply-To: <20160414.152601.1422370571524886675.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why do you call all of these offloads the "slowpath"?

We term by 'slowpath' all the non {data,fast}path configurations,
I.e., everything that doesn't really involves the ingress/egress handling
of packets but rather the infrastructure changes surrounding it.

That exactly what we have in this patch - adding the ndo hooks
necessary for configuring the FW/HW in the proper mode to support
vxlan tunnels.

Only the last patch in the series is actually adding the fastpath stuff.
