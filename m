From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/5] e1000e: separate mutex usage between NVM
 and PHY/CSR register for ICHx/PCH
Date: Mon, 26 Oct 2009 16:17:22 -0700 (PDT)
Message-ID: <20091026.161722.242384657.davem@davemloft.net>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
	<20091026212343.9682.56885.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49859
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754664AbZJZXQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 19:16:58 -0400
In-Reply-To: <20091026212343.9682.56885.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Oct 2009 14:23:43 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Accesses to NVM and PHY/CSR registers on ICHx/PCH-based parts are protected
> from concurrent accesses with a mutex that is acquired when the access is
> initiated and released when the access has completed.  However, the two
> types of accesses should not be protected by the same mutex because the
> driver may have to access the NVM while already holding the mutex over
> several consecutive PHY/CSR accesses which would result in livelock.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
