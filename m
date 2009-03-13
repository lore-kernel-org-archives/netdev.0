From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc911x: check for FFWD success before checking
 for timeout
Date: Fri, 13 Mar 2009 12:14:38 -0700 (PDT)
Message-ID: <20090313.121438.17663218.davem@davemloft.net>
References: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com,
	juha_motorsportcom@luukku.com, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49346
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbZCMTOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 15:14:53 -0400
In-Reply-To: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed,  4 Mar 2009 17:33:24 +0000

> This patch from Juha Leppanen suppresses a false warning if a fast
> forward operation succeeds on the very last attempt.
> 
> Juha> If smsc911x_reg_read loop is executed 500 times, timeout reaches 0
> Juha> and the 500th smsc911x_reg_read result in val is ignored. If
> Juha> testing order is changed, then val is checked first. The 500th
> Juha> reg_read might be GOOD, why ignore it!
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6
