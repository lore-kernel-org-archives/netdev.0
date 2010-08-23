From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: use bitmap library
Date: Sun, 22 Aug 2010 20:52:31 -0700 (PDT)
Message-ID: <20100822.205231.116364886.davem@davemloft.net>
References: <1282382688-5786-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolandd@cisco.com
To: akinobu.mita@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752818Ab0HWDwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Aug 2010 23:52:14 -0400
In-Reply-To: <1282382688-5786-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 21 Aug 2010 18:24:48 +0900

> Use bitmap_set() and bitmap_clear()
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

Unlike loops calling set_bit() and clear_bit(), bitmap_set() and
bitmap_clear() are not atomic.

Are you sure this is ok here?
