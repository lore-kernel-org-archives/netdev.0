From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Thu, 22 Feb 2007 00:21:47 -0800 (PST)
Message-ID: <20070222.002147.10299202.davem@davemloft.net>
References: <45D97D5D.9040101@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrea.baiocchi@uniroma1.it,
	francesco@net.infocom.uniroma1.it
To: angelo.castellani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751475AbXBVIVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 03:21:48 -0500
In-Reply-To: <45D97D5D.9040101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Date: Mon, 19 Feb 2007 11:35:09 +0100

> From: Angelo P. Castellani <angelo.castellani@gmail.con>
> 
> RFC3742: limited slow start
> 
> See http://www.ietf.org/rfc/rfc3742.txt
> 
> Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>
> ---
> 
> To allow code reutilization I've added the limited slow start procedure 
> as an exported symbol of linux tcp congestion control.
> 
> On large BDP networks canonical slow start should be avoided because it 
> requires large packet losses to converge, whereas at lower BDPs slow 
> start and limited slow start are identical. Large BDP is defined through 
> the max_ssthresh variable.
> 
> I think limited slow start could safely replace the canonical slow start 
> procedure in Linux.
 ...
> p.s.: in the attached patch is added an exported function currently used 
> only by YeAH TCP

Please never submit patches like this, submit the infrastructure
FIRST, then submit the stuff that uses it.  When a sequence of patches
is applied, in sequence, the tree should build properly (even with all
available new options enabled) at each step along the way.

Otherwise we have the situation we have now, in that YeaH is in my
tree but doesn't build successfully.

What I'm going to do to "fix" this, is yank YeaH implementation out
of my tree, add this second patch first, then add the YeaH patch
back.

Please never do this again.
