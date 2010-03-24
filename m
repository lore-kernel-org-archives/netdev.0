From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/09] net: remove trailing spaces in messages
Date: Wed, 24 Mar 2010 14:11:58 -0700 (PDT)
Message-ID: <20100324.141158.43422101.davem@davemloft.net>
References: <201003241840.18701.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, samuel@sortiz.org,
	benh@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	e1000-devel@lists.sourceforge.net
To: elendil@planet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36529
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751988Ab0CXVLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 17:11:35 -0400
In-Reply-To: <201003241840.18701.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frans Pop <elendil@planet.nl>
Date: Wed, 24 Mar 2010 18:40:15 +0100

> This is the second patchset to remove trailing spaces in kernel messages. 
> Patches in this set cover networking code, excepting wireless which will be 
> submitted in a separate set.
> 
> Patches have been rebased against current net-next.
> 
> Benefits are:
> - general cleanup and consistency
> - minor reduction in kernel size and user's log file size
> - reduced annoyance for people writing logcheck rules
> 
> I have run the patches through checkpatch and included some fixes, but in 
> most cases the files are so horrible in general that fixing the warnings 
> purely for these changes doesn't make sense.

All applied, but I have to make some fixups.

For example, GIT warns about trailing whitespace on any lines that you
touched so I had to fix those up before putting them into the tree.

Thanks.
