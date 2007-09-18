From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Cleanup list walking in setup_net and
 cleanup_net
Date: Tue, 18 Sep 2007 13:21:07 -0700 (PDT)
Message-ID: <20070918.132107.04054310.davem@davemloft.net>
References: <46EF871D.8050900@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754442AbXIRUVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 16:21:18 -0400
In-Reply-To: <46EF871D.8050900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 18 Sep 2007 12:06:53 +0400

> I proposed introducing a list_for_each_entry_continue_reverse macro
> to be used in setup_net() when unrolling the failed ->init callback.
> 
> Here is the macro and some more cleanup in the setup_net() itself
> to remove one variable from the stack :) The same thing is for the
> cleanup_net() - the existing list_for_each_entry_reverse() is used.
> 
> Minor, but the code looks nicer.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied, thanks Pavel.
