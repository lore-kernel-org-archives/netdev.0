From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC] inter address family IPsec tunnel on the fly
Date: Fri, 21 Mar 2008 04:20:48 -0700 (PDT)
Message-ID: <20080321.042048.198566667.davem@davemloft.net>
References: <47D2A6B5.101@miyazawa.org>
	<20080308.141506.193713220.davem@davemloft.net>
	<20080314122314.b877cfab.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753988AbYCULUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 07:20:32 -0400
In-Reply-To: <20080314122314.b877cfab.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 14 Mar 2008 12:23:14 +0900

> I made the patch for that.
> 
> Signed-off-by Kazunori MIYAZAWA <kazunori@miyazawa.org>

This looks fine.

Because the inner mode is resolved at xfrm creation time, I think the
overall cost is small enough that we can avoid the config option.
And anyways, if something matters for performance we can fix that.

Could you respin this patch with it removed?

Thank you.
