From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/2] igb: do not allow phy sw reset code to
 make calls to null pointers
Date: Mon, 14 Sep 2009 17:09:03 -0700 (PDT)
Message-ID: <20090914.170903.87884938.davem@davemloft.net>
References: <20090914182253.4859.11176.stgit@localhost.localdomain>
	<20090914182312.4859.21938.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753918AbZIOAIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:08:47 -0400
In-Reply-To: <20090914182312.4859.21938.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 14 Sep 2009 11:23:13 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> In the case of fiber and serdes adapters we were seeing issues with ethtool
> -t causing kernel panics due to null function pointers.  To prevent this we
> need to exit out of the phy reset code in the event that we do not have a
> valid phy.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>

Applied.
