From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Thu, 27 Sep 2007 12:45:52 -0700 (PDT)
Message-ID: <20070927.124552.69400277.davem@davemloft.net>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
	<46FB6F1E.8070105@fr.ibm.com>
	<m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clg@fr.ibm.com, containers@lists.osdl.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55056
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756524AbXI0Tpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:45:52 -0400
In-Reply-To: <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 11:14:33 -0600

> Thanks for pointing this out, it's on my todo list to look into,
> and ensure we resolve.
> 
> I'm confused because my notes have 0x80000000 for the pid namespace,
> and 0x40000000 for the time namespace.

Eric, pick an appropriate new non-conflicting number NOW.

This adds unnecessary extra work for Andrew Morton, which he has
enough of already.
