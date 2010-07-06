From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] igb: drop support for UDP hashing w/ RSS
Date: Mon, 05 Jul 2010 19:08:54 -0700 (PDT)
Message-ID: <20100705.190854.241908425.davem@davemloft.net>
References: <20100702060056.16863.23072.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757743Ab0GFCIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:08:40 -0400
In-Reply-To: <20100702060056.16863.23072.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 23:01:05 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change removes UDP from the supported protocols for RSS hashing.  The
> reason for removing this protocol is because IP fragmentation was causing a
> network flow to be broken into two streams, one for fragmented, and one for
> non-fragmented and this in turn was causing out-of-order issues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
