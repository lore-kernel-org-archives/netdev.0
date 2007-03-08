From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skge- "soft lockup on CPU#0" with mtu=9000 (2.6.20.1 + web100
 patch)
Date: Thu, 8 Mar 2007 13:48:11 -0800
Message-ID: <20070308134811.38a8ec81@freekitty>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
	<20070308113427.6344a7f6@freekitty>
	<Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Stromsoe <cbs@cts.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:38078 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030680AbXCHVsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 16:48:19 -0500
In-Reply-To: <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Mar 2007 13:31:13 -0800 (PST)
Chris Stromsoe <cbs@cts.ucla.edu> wrote:

> Thanks.  That fixes the soft lockup.
> 
> I've got another problem now.  The cards I'm using are dual port 
> (sk-9844).  I am bonding both ports together.
> 
> The card presents as eth2 and eth3.  If I remove eth2 from the bond so 
> that eth3 is the active interface, I get a hard lock (nothing prints to 
> serial console, sysrq isn't responsive) and have to power cycle.
> 
> This is with plain 2.6.20.1.  I also tested using skge.[ch] from the 
> current netdev git tree.

Which form of bonding failover, there are locking issues with some
of the bonding modes. You should ask on the bonding mailing list.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
