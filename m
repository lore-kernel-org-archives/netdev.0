From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hsr: Use setup_timer and mod_timer.
Date: Mon, 16 May 2016 14:01:07 -0400 (EDT)
Message-ID: <20160516.140107.648493980838894656.davem@davemloft.net>
References: <1463321265-11577-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: falakreyaz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbcEPSBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:01:09 -0400
In-Reply-To: <1463321265-11577-1-git-send-email-falakreyaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Date: Sun, 15 May 2016 19:37:44 +0530

> The function setup_timer combines the initialization of a timer with the
> initialization of the timer's function and data fields. The mulitiline
> code for timer initialization is now replaced with function setup_timer.
> 
> Also, quoting the mod_timer() function comment:
> -> mod_timer() is a more efficient way to update the expire field of an
>    active timer (if the timer is inactive it will be activated).
> 
> Use setup_timer() and mod_timer() to setup and arm a timer, making the
> code compact and aid readablity.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Applied.
