From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Buffer overflow
Date: Thu, 30 Jul 2009 13:28:14 -0700 (PDT)
Message-ID: <20090730.132814.219881625.davem@davemloft.net>
References: <4A702A02.30509@gmail.com>
	<4A70C6FF.9060302@gmail.com>
	<4A716C13.6030208@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45245
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751234AbZG3U2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:28:08 -0400
In-Reply-To: <4A716C13.6030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Thu, 30 Jul 2009 11:46:59 +0200

> If arp_format_neigh_entry() can be called with n->dev->addr_len == 0, then a
> write to hbuffer[-1] occurs.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
