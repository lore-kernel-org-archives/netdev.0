From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc911x: improve EEPROM loading timeout logic in
 open
Date: Fri, 13 Mar 2009 12:14:47 -0700 (PDT)
Message-ID: <20090313.121447.186963981.davem@davemloft.net>
References: <1236188005-14065-1-git-send-email-steve.glendinning@smsc.com>
	<1236188005-14065-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roel.kluin@gmail.com,
	juha_motorsportcom@luukku.com, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753966AbZCMTPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 15:15:01 -0400
In-Reply-To: <1236188005-14065-2-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed,  4 Mar 2009 17:33:25 +0000

> This patch from Juha Leppanen suppresses a false warning if the eeprom
> load succeeds on the very last attempt.
> 
> Juha> In function smsc911x_open smsc911x_reg_read+udelay can be run 50
> Juha> times with timeout reaching -1, and the following if statetement
> Juha> does not catch the timeout and no warning is issued. Also if the
> Juha> 50th smsc911x_reg_read is GOOD, loop is exited with timeout as 0
> Juha> and bogus warning issued.  Replace testing order and --timeout
> Juha> instead of timeout-- and now max 50 smsc911x_reg_read's are done,
> Juha> with max 49 udelays.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6
