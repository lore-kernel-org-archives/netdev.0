From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Change in inline keyword usage.
Date: Sun, 27 Mar 2011 18:41:33 -0700 (PDT)
Message-ID: <20110327.184133.258122355.davem@davemloft.net>
References: <1301215710-8112-1-git-send-email-balajig81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: balajig81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54547
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752744Ab1C1BmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:42:12 -0400
In-Reply-To: <1301215710-8112-1-git-send-email-balajig81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "G.Balaji" <balajig81@gmail.com>
Date: Sun, 27 Mar 2011 14:18:30 +0530

> 
> Signed-off-by: G.Balaji <balajig81@gmail.com>

The tg3.c case was already taken care of by another patch
submission, please resend this patch with just the other
portion and please write a better commit message.

"Change in inline keyword usage" doesn't tell us anything.

What are you changing?  Why are you changing it?  What subsystem
are you making these changes in?

F.e. a better submission would be:

--------------------
Subject: [PATCH] drivers net: Fix declaration ordering in inline functions.

It should be "static inline foo" instead of "static foo inline."

Signed-off-by: ...
--------------------
