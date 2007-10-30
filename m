From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1][NETNS] resend: fix net released by rcu callback
Date: Tue, 30 Oct 2007 15:39:05 -0700 (PDT)
Message-ID: <20071030.153905.34390407.davem@davemloft.net>
References: <20071030162139.954791193@mai.toulouse-stg.fr.ibm.com>
	<20071030162305.458123510@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35803
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751766AbXJ3WjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 18:39:21 -0400
In-Reply-To: <20071030162305.458123510@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Tue, 30 Oct 2007 17:21:40 +0100

> When a network namespace reference is held by a network subsystem,
> and when this reference is decremented in a rcu update callback, we
> must ensure that there is no more outstanding rcu update before 
> trying to free the network namespace.
> 
> In the normal case, the rcu_barrier is called when the network namespace
> is exiting in the cleanup_net function.
> 
> But when a network namespace creation fails, and the subsystems are
> undone (like the cleanup), the rcu_barrier is missing.
> 
> This patch adds the missing rcu_barrier.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied, thanks Daniel.
