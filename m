From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 07/20] ixgbe: consolidate all setting of
 MRQC into one function
Date: Thu, 19 Aug 2010 16:46:26 -0700 (PDT)
Message-ID: <20100819.164626.115911857.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233539.10335.93283.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962Ab0HSXqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:10 -0400
In-Reply-To: <20100819233539.10335.93283.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:35:41 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change simplifies the configuration of MRQC by consolidating the
> setting of it into one function. As such the register is no longer set in
> multiple places which should make any future changes easier to work with.
> In addition we can combine RSS related register writes into the call since
> enabling all of those bits without enabling RSS itself in MRQC should have
> no effect.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
