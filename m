From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ethoc: fix buffer address mapping
Date: Wed, 07 Oct 2009 03:42:09 -0700 (PDT)
Message-ID: <20091007.034209.40132481.davem@davemloft.net>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758831AbZJGKmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:42:14 -0400
In-Reply-To: <1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Chou <thomas@wytron.com.tw>
Date: Mon,  5 Oct 2009 17:33:18 +0800

> The pointer address in buffer descriptors is physical address. The
> pointer that processor used to access packet is virtual address.
> 
> Though the higher bits of pointer address used by the MAC may be
> truncated to zero in special case, it is not always true in larger
> designs.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
