From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dst: don't inline dst_ifdown
Date: Tue, 13 Apr 2010 03:34:12 -0700 (PDT)
Message-ID: <20100413.033412.123477670.davem@davemloft.net>
References: <20100412103805.13ac6339@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37606
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752766Ab0DMKeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:34:08 -0400
In-Reply-To: <20100412103805.13ac6339@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 12 Apr 2010 10:38:05 -0700

> The function dst_ifdown is called only two places but in a non-
> performance critical code path, there is no reason to inline it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
