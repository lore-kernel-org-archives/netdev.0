From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 01/15] igb: remove unused temp variable
 from stats clearing path
Date: Tue, 06 Oct 2009 15:20:35 -0700 (PDT)
Message-ID: <20091006.152035.136392892.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47885
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933696AbZJFWUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:20:40 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:31:25 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> There is a temp variable in the stats clearing path that isn't needed since
> the results from the stats read can be immediately discared.  Since it
> isn't needed we might as well just drop it from the function call.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
