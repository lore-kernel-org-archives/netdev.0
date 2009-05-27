From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/4] igb: Implement reading of reg RQDPC
 (Receive Queue Drop Packet Count)
Date: Tue, 26 May 2009 20:36:15 -0700 (PDT)
Message-ID: <20090526.203615.66405421.davem@davemloft.net>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
	<20090526235030.28231.35089.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hawk@comx.dk
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48858
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752895AbZE0DgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 23:36:16 -0400
In-Reply-To: <20090526235030.28231.35089.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 May 2009 16:50:31 -0700

> Based on the previous patches from Jesper Dangaard Brouer <hawk@comx.dk>
> 
> Implement reading the per queue drop stats register
> RQDPC (Receive Queue Drop Packet Count).  It counts the number of
> packets dropped by a queue due to lack of descriptors available.
> 
> Notice RQDPC (Receive Queue Drop Packet Count) stats only gets
> incremented, if the DROP_EN bit it set (in the SRRCTL register
> for that queue).  If DROP_EN bit is NOT set, then the some what
> equivalent count is stored in RNBC (not per queue basis).
> 
> The RQDPC register is only 12 bit, thus the precision might
> suffer due to overrun in-netween the watchdog polling interval.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
