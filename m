From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] NET/PHY: Eliminate the algorithm of forced ethernet speed reduction
Date: Sat, 26 Jan 2013 10:59:53 +0100
Message-ID: <20130126095953.GA9403@electric-eye.fr.zoreil.com>
References: <1359108607.357711816@f237.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kirill Kapranov <kapranoff@inbox.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44635 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199Ab3AZK3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2013 05:29:24 -0500
Content-Disposition: inline
In-Reply-To: <1359108607.357711816@f237.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kirill Kapranov <kapranoff@inbox.ru> :
> NET/PHY: Eliminate the forced speed reduction algorithm.
> In case of the fixed speed set up for NIC 
> (e.g. ethtool -s eth0 autoneg off speed 100 duplex full)
> with ethernet cable plugged off, mentioned algorithm
> slows down NIC speed, so the further "hooking up" gives
> no result. AFAIK, this behaviour is not RFCs' recommended.
> Tested at 2.6.38.7, applicable up to for 3.0.4. 

(your mail user agent completely messed the patch. Please fix it.)

I makes sense but which RFC (?) does state that said algorithm
should not apply to the autonegotiated case as well ?

-- 
Ueimor
