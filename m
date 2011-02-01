From: David Miller <davem@davemloft.net>
Subject: Re: rps_flow_table bug fix
Date: Mon, 31 Jan 2011 16:24:28 -0800 (PST)
Message-ID: <20110131.162428.232748898.davem@davemloft.net>
References: <alpine.DEB.2.00.1101311618140.13796@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43022
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752920Ab1BAAXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 19:23:53 -0500
In-Reply-To: <alpine.DEB.2.00.1101311618140.13796@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 31 Jan 2011 16:21:43 -0800 (PST)

Tom, please set your email subject correctly.

> Subject: [PATCH] net: Check rps_flow_table when RPS map length is 1
> 
> In get_rps_cpu, add check that the rps_flow_table for the device is
> NULL when trying to take fast path when RPS map length is one.
> Without this, RFS is effectively disabled if map length is one which
> is not correct.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks.
