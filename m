From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax88796: start_xmit fix using net_device_ops
Date: Wed, 14 Jan 2009 21:06:10 -0800 (PST)
Message-ID: <20090114.210610.130931205.davem@davemloft.net>
References: <20090114073827.26909.56261.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org, shemminger@vyatta.com,
	ben-linux@fluff.org
To: magnus.damm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756114AbZAOFGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 00:06:09 -0500
In-Reply-To: <20090114073827.26909.56261.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>
Date: Wed, 14 Jan 2009 16:38:27 +0900

> This patch hooks up the start_xmit/tx_timeout/get_stats callbacks
> in the ax88796 driver since they no longer are installed by the
> lib8390 code. Without this patch the function dev_hard_start_xmit()
> crashes due to a start_xmit callback with the value NULL.
> 
> While at it, update the ax88796 driver to make use of use of struct
> net_device_ops.
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

Applied, thanks a lot Magnus.
