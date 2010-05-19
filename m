From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/7] ixgbe: fix header len when unsplit packet
 overflows to data buffer
Date: Tue, 18 May 2010 19:44:33 -0700 (PDT)
Message-ID: <20100518.194433.191137438.davem@davemloft.net>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46529
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752189Ab0ESCoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:44:25 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 May 2010 19:00:03 -0700

> From: Shannon Nelson <shannon.nelson@intel.com>
> 
> When in packet split mode, packet type is not recognized, and the packet is
> larger than the header size, the 82599 overflows the packet into the data
> area, but doesn't set the HDR_LEN field.  We can safely assume the length
> is the current header size.  This fixes an obscure corner case that can be
> triggered by non-ip packet headers or (more likely) by disabling the L2
> packet recognition.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
