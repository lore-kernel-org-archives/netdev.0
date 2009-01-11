From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc911x: fix smsc911x_reg_read compiler warning
Date: Sun, 11 Jan 2009 00:14:33 -0800 (PST)
Message-ID: <20090111.001433.209033327.davem@davemloft.net>
References: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56114
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750946AbZAKIOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:14:32 -0500
In-Reply-To: <1231594169-24988-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Sat, 10 Jan 2009 13:29:28 +0000

> if this code path is ever hit, the platform_data struct isn't properly
> configured with a bus width flag so the device won't work (hence the
> BUG()).
> 
> This patch adds a dummy return statement to eliminate this compiler
> warning:
> 
> drivers/net/smsc911x.c: In function 'smsc911x_reg_read':
> drivers/net/smsc911x.c:148: warning: control reaches end of non-void function
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
