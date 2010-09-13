From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/llc: make opt unsigned in llc_ui_setsockopt()
Date: Mon, 13 Sep 2010 12:45:01 -0700 (PDT)
Message-ID: <20100913.124501.59676416.davem@davemloft.net>
References: <20100910115616.GD5959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, opurdila@ixiacom.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35892
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752833Ab0IMTon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 15:44:43 -0400
In-Reply-To: <20100910115616.GD5959@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 10 Sep 2010 13:56:16 +0200

> The members of struct llc_sock are unsigned so if we pass a negative
> value for "opt" it can cause a sign bug.  Also it can cause an integer
> overflow when we multiply "opt * HZ".
> 
> CC: stable@kernel.org
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
