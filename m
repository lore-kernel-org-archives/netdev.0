From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: exclude registers with read side
 effects from register dumps
Date: Sun, 11 Jul 2010 17:34:00 -0700 (PDT)
Message-ID: <20100711.173400.13755695.davem@davemloft.net>
References: <1278894512-6358-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41165
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754888Ab0GLAdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 20:33:46 -0400
In-Reply-To: <1278894512-6358-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Sun, 11 Jul 2010 17:28:32 -0700

> A few registers have side effects on reads, eg FIFO pointers that
> auto advance or mailboxes which change ownership when read.  They are
> unsafe to read so exclude them from ethtool register dumps.
> 
> Bump ethtool_regs.version to indicate the changed register set.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied, thank you.
