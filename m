From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tc: policing requires a rate estimator
Date: Tue, 25 Nov 2008 21:14:13 -0800 (PST)
Message-ID: <20081125.211413.167583749.davem@davemloft.net>
References: <20081125101656.52348bdd@extreme>
	<20081125102113.371db7b1@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56667
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751056AbYKZFON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:14:13 -0500
In-Reply-To: <20081125102113.371db7b1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 25 Nov 2008 10:21:13 -0800

> Found that while trying average rate policing, it was possible to
> request average rate policing without a rate estimator. This results
> in no policing which is harmless but incorrect.
> 
> Since policing could be setup in two steps, need to check
> in the kernel.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
