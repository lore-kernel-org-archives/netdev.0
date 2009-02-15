From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] Remove mutex_trylock and associated WARN on
 failure.
Date: Sat, 14 Feb 2009 23:46:19 -0800 (PST)
Message-ID: <20090214.234619.95630749.davem@davemloft.net>
References: <20090212095304.6369.47737.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	david.graham@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36175
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750718AbZBOHqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 02:46:25 -0500
In-Reply-To: <20090212095304.6369.47737.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 12 Feb 2009 01:53:10 -0800

> Single-thread access must be ensured for ICH8 NVM and PHY operations.
> This synchronization is provided by the nvm_mutex. To assist in
> understanding the contexts from which this code could be reached,
> a WARN was output if the mutex was not going to be immediately
> acquirable (if !mutex_trylock()). The code has now been optimized,
> and we have verified that the few remaining mutex contentions are
> reasonable and non-blocking, and it is time to remove the
> mutex_trylock() and WARN messages.
> 
> Signed-off-by: dave graham <david.graham@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
