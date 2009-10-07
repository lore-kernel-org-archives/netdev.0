From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] ethoc: align received packet to make IP header at
 word boundary
Date: Wed, 07 Oct 2009 03:42:04 -0700 (PDT)
Message-ID: <20091007.034204.124834722.davem@davemloft.net>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758827AbZJGKmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:42:09 -0400
In-Reply-To: <1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Chou <thomas@wytron.com.tw>
Date: Mon,  5 Oct 2009 17:33:19 +0800

> The packet buffer is allocated at 4 bytes boundary, but the IP header
> length and version bits is located at byte 14. These bit fields access
> as 32 bits word and caused exception on processors that do not support
> unaligned access.
> 
> The patch adds 2 bytes offset to make the bit fields word aligned.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
