From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 02 Oct 2009 10:56:59 -0700 (PDT)
Message-ID: <20091002.105659.102583702.davem@davemloft.net>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, greg@kroah.com, dm-devel@redhat.com,
	zbr@ioremap.net, linux-fbdev-devel@lists.sourceforge.net
To: philipp.reisner@linbit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754419AbZJBR4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 13:56:39 -0400
In-Reply-To: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philipp Reisner <philipp.reisner@linbit.com>
Date: Fri,  2 Oct 2009 14:40:03 +0200

> Affected: All code that uses connector, in kernel and out of mainline
> 
> The connector, as it is today, does not allow the in kernel receiving
> parts to do any checks on privileges of a message's sender.
> 
> I know, there are not many out there that like connector, but as
> long as it is in the kernel, we have to fix the security issues it has!
> 
> Please either drop connector, or someone who feels a bit responsible
> and has our beloved dictator's blessing, PLEASE PLEASE PLEASE take 
> this into your tree, and send the pull request to Linus.
> 
> Patches 1 to 4 are already Acked-by Evgeny, the connector's maintainer.
> Patches 5 to 7 are the obvious fixes to the connector user's code.
> 
> For convenience these patches are also available as git tree:
> git://git.drbd.org/linux-2.6-drbd.git connector-fix

All applied to net-2.6, I'll push this out to Linus later
today.
