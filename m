From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: DCB: remove DCB check config
Date: Fri, 15 Oct 2010 09:27:56 -0700 (PDT)
Message-ID: <20101015.092756.71096200.davem@davemloft.net>
References: <20101015051846.32242.1734.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58779
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754545Ab0JOQ1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 12:27:34 -0400
In-Reply-To: <20101015051846.32242.1734.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 14 Oct 2010 22:21:22 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Remove a DCB check config from DCB configuration we
> continue to configure DCB even if it fails so don't
> even bother to check.  Plus user space (lldpad) checks
> this before programming the hw anyways.
> 
> Worse case is we program some values into the hw that
> don't make total sense resulting in incorrect bandwidth
> allocation.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
