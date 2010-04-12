From: Michael Barkowski <michaelbarkowski@ruggedcom.com>
Subject: hdlc_ppp: why no detach()?
Date: Mon, 12 Apr 2010 10:15:28 -0400
Message-ID: <4BC32B00.1030600@ruggedcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ruggedcom.com ([204.50.148.11]:25238 "EHLO
	mail2.ruggedcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab0DLOUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 10:20:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Krzyztof,

I am looking at your hdlc_ppp code and I don't understand: why is there
not the equivalent of fr_detach() in there?

pc8300_drv:cpc_remove_one() frees netdevs quite confidently but I wonder
how it can be so sure that there are not skbs in hdlc_ppp's tx_queue
associated with those devices before freeing them....

Even if you wanted to switch a device from PPP to Frame Relay, I don't
see the method right now.  If I may ask, please, what am I missing?

If you agree there is a need for detach(), I would be happy to work on
it and make a submission.

thanks for your time,

-- 
Michael Barkowski
RuggedCom, Inc.

