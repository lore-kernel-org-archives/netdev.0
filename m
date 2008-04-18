From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/3] WAN: new PPP code for generic HDLC
Date: Fri, 18 Apr 2008 15:03:36 -0700 (PDT)
Message-ID: <20080418.150336.180346848.davem@davemloft.net>
References: <200804182046.m3IKk9hc014616@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khc@pm.waw.pl, jeff@garzik.org,
	paulkf@microgate.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbYDRWDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 18:03:34 -0400
In-Reply-To: <200804182046.m3IKk9hc014616@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 18 Apr 2008 13:46:09 -0700

> From: Krzysztof Halasa <khc@pm.waw.pl>
> 
> New synchronous PPP implementation for generic HDLC.
> 
> Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Paul Fulghum <paulkf@microgate.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This patch went through Jeff's tree and I rejected it
because it's not the right way to solve this problem
and it gives us a 3rd implementation of PPP protocol
handling in the tree which makes even less sense.

Please drop, thanks Andrew.
