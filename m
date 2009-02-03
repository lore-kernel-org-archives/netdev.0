From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: limit reaches -1, but 0 tested
Date: Mon, 02 Feb 2009 23:19:59 -0800 (PST)
Message-ID: <20090202.231959.127283027.davem@davemloft.net>
References: <4984473C.1040508@gmail.com>
	<20090201.015931.127677783.davem@davemloft.net>
	<4985D8AF.1040009@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37116
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751476AbZBCHUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 02:20:02 -0500
In-Reply-To: <4985D8AF.1040009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 01 Feb 2009 18:15:27 +0100

> while (limit--)
> 	if (test())
> 		break;
> 
> if (limit <= 0)
> 	goto test_failed;
> 
> In the last iteration, limit is decremented after the test to 0.
> If just thereafter test() succeeds and a break occurs, the goto
> still occurs because limit is 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Also applied, thanks.
