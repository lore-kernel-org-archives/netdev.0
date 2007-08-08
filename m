From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] NetLabel: add missing rcu_dereference() calls in
 the LSM domain mapping hash table
Date: Tue, 07 Aug 2007 17:53:33 -0700 (PDT)
Message-ID: <20070807.175333.65650330.davem@davemloft.net>
References: <20070807205458.599982536@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33755
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762461AbXHHAxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 20:53:34 -0400
In-Reply-To: <20070807205458.599982536@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul Moore" <paul.moore@hp.com>
Date: Tue, 07 Aug 2007 16:54:50 -0400

> The LSM domain mapping head table pointer was not being referenced via the RCU
> safe dereferencing function, rcu_dereference().  This patch adds those missing
> calls to the NetLabel code.
> 
> This has been tested using recent linux-2.6 git kernels with no visible
> regressions.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Patch applied, thanks Paul.
