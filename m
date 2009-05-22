From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/2] ixgbe: only register DCA requester
 once
Date: Thu, 21 May 2009 17:20:56 -0700 (PDT)
Message-ID: <20090521.172056.241948576.davem@davemloft.net>
References: <20090521230639.21776.59261.stgit@localhost.localdomain>
	<20090521230712.21776.83286.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33548
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754314AbZEVAU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 20:20:58 -0400
In-Reply-To: <20090521230712.21776.83286.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 May 2009 16:07:12 -0700

> The current driver tries to re-register the DCA requester after reset and
> this is not correct.  This change makes it so all we are doing is resetting
> the DCA registers after reset and not re-adding the requester.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
