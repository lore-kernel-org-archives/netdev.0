From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] irda: fix read buffer overflow
Date: Sun, 09 Aug 2009 21:53:15 -0700 (PDT)
Message-ID: <20090809.215315.214313189.davem@davemloft.net>
References: <200908062306.n76N63iE005813@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, roel.kluin@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752317AbZHJExG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:53:06 -0400
In-Reply-To: <200908062306.n76N63iE005813@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 06 Aug 2009 16:06:03 -0700

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> io[i] is read before the bounds check on i, order should be reversed.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
