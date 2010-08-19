From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 04/20] ixgbe: combine two modifications of
 TXDCTL into one
Date: Thu, 19 Aug 2010 16:46:08 -0700 (PDT)
Message-ID: <20100819.164608.183030288.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233425.10335.67211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753796Ab0HSXpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:45:51 -0400
In-Reply-To: <20100819233425.10335.67211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:34:27 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> In ixgbe_up_complete we were doing a read-modify-write of TXDCTL followed
> by another one just a few lines further down.  Instead of performing two
> separate read-modify-writes it would make more sense to combine the two
> into one.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
