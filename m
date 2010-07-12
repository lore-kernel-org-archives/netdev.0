From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at1700: fix double free_irq
Date: Sun, 11 Jul 2010 18:15:58 -0700 (PDT)
Message-ID: <20100711.181558.45891981.davem@davemloft.net>
References: <1278678686-7215-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	joe@perches.com, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33106
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752608Ab0GLBPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 21:15:43 -0400
In-Reply-To: <1278678686-7215-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Fri,  9 Jul 2010 16:31:26 +0400

> free_irq() is called both in net_close() and cleanup_card().  Since it
> is requested in at1700_probe1(), leave free_irq() only in cleanup_card()
> for balance.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
