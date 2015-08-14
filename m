From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ppp: implement x-netns support
Date: Thu, 13 Aug 2015 21:20:04 -0700 (PDT)
Message-ID: <20150813.212004.553374390201687089.davem@davemloft.net>
References: <cover.1439471390.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41346 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbHNEUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:20:05 -0400
In-Reply-To: <cover.1439471390.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 13 Aug 2015 15:28:02 +0200

> This series allows PPP devices to reside in a different netns from the
> PPP unit/channels. Packets only cross netns boundaries when they're
> transmitted between the net_device and the PPP unit (units and channels
> always remain in their creation namespace).
> So only PPP units need to handle cross namespace operations. Channels
> and lower layer protocols aren't affected.
> 
> Patch #1 is a bug fix for an existing namespace deletion bug and has
> been separetly sent to net.
> Patch #2 is the actual x-netns implementation.

Patch #1 needs to be respun with the change I requested.

And this is not the way to submit things that have dependencies
upon bug fixes.

First you submit the bug fix only.  Then you wait for the fix to
propragate from 'net' into 'net-next', and then you can submit
your feature patch which depends upon the fix.

Thank you.
