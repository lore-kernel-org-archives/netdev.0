From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Tue, 09 Oct 2007 13:12:11 -0700 (PDT)
Message-ID: <20071009.131211.85410709.davem@davemloft.net>
References: <470B71CD.3000706@openvz.org>
	<OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, devel@openvz.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50110
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753199AbXJIUMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:12:12 -0400
In-Reply-To: <OF54650AF1.A1051792-ON8825736F.00588F0B-8825736F.00597D24@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 9 Oct 2007 09:18:25 -0700

> Ifindex's have to uniquely identify the interface (virtual or
> otherwise) to remote queriers (not just local applications), so
> unless you pay the price of separating all the SNMP MIBs per
> namespace too, it seems you'll need some way to remap these for SNMP
> queries, right?

I don't see how it can work even with per-namespace MIBs,
the interface indexes have to be unique per "system".


