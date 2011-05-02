From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sysctl: net: call unregister_net_sysctl_table where
 needed
Date: Mon, 02 May 2011 16:12:32 -0700 (PDT)
Message-ID: <20110502.161232.70214722.davem@davemloft.net>
References: <1304250241-26138-1-git-send-email-lucian.grijincu@gmail.com>
	<BANLkTi=0-2aHDBtY2P794upF9brrW48aNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucian.grijincu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751292Ab1EBXNG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 19:13:06 -0400
In-Reply-To: <BANLkTi=0-2aHDBtY2P794upF9brrW48aNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Sun, 1 May 2011 13:48:04 +0200

> On Sun, May 1, 2011 at 1:44 PM, Lucian Adrian Grijincu
> <lucian.grijincu@gmail.com> wrote:
>> ctl_table_headers registered with register_net_sysctl_table should
>> have been unregistered with the equivalent unregister_net_sysctl_table
>>
>> Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
> 
> 
> David: I sent you this patch a while back but it was mixed with other
> unrelated patches that were mostly ignored.
> 
> Again, to clarify: it does not matter at the moment if
> register_net_sysctl_table or unregister_sysctl_table is called because
> both to the same thing:
 ...
> We should either get rid of unregister_net_sysctl_table or use it consistently.

Applied to net-2.6, thanks Lucian.
