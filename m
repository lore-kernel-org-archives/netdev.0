From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/6] igb/ixgbe: remove unecessary checks for
 CHECKSUM_UNNECESSARY
Date: Tue, 28 Apr 2009 01:54:38 -0700 (PDT)
Message-ID: <20090428.015438.178164366.davem@davemloft.net>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
	<20090428083532.32417.26831.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37610
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753441AbZD1Iyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:54:45 -0400
In-Reply-To: <20090428083532.32417.26831.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:35:33 -0700

> Both of these drivers do a check to verify ip_summed is set to
> CHECKSUM_UNNECESSARY prior to passing the packet to GRO.  GRO itself
> already does such a check so it is redundant and can be removed as this
> will likely cause out of order issues when receiving a packet that didn't
> pass checksum validation.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
