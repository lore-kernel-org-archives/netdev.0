From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] teach ipconfig about the MTU option in DHCP
Date: Tue, 19 May 2009 15:32:03 -0700 (PDT)
Message-ID: <20090519.153203.223534629.davem@davemloft.net>
References: <4A12F4EE.7070305@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752989AbZESWcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:32:05 -0400
In-Reply-To: <4A12F4EE.7070305@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Tue, 19 May 2009 12:05:34 -0600

> The DHCP spec allows the server to specify the MTU.  This can be useful
> for netbooting with UDP-based NFS-root on a network using jumbo frames.
> This patch allows the kernel IP autoconfiguration to handle this option
> correctly.
> 
> It would be possible to use initramfs and add a script to set the MTU,
> but that seems like a complicated solution if no initramfs is otherwise
> necessary, and would bloat the kernel image more than this code would.
> 
> This patch was originally submitted to LKML in 2003 by Hans-Peter Jansen.
> 
> Signed-off-by: Chris Friesen <cfriesen@nortel.com>

Looks good, applied, thanks.
