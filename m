From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 09/20] ixgbe: pull PSRTYPE configuration
 into a separate function
Date: Thu, 19 Aug 2010 16:46:36 -0700 (PDT)
Message-ID: <20100819.164636.260110269.davem@davemloft.net>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
	<20100819233624.10335.67259.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753983Ab0HSXqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:46:20 -0400
In-Reply-To: <20100819233624.10335.67259.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 16:36:27 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The configuration of PSRTYPE was being done conditionally on if packet
> split is enabled or not.  It can be configured always since it will not
> have any effect when packet split is not enabled.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
