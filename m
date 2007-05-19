From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rfkill: Fix check for correct rfkill allocation
Date: Sat, 19 May 2007 11:34:13 -0700 (PDT)
Message-ID: <20070519.113413.108744392.davem@davemloft.net>
References: <200705191408.44138.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, dtor@insightbb.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: ivdoorn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757023AbXESSeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 14:34:10 -0400
In-Reply-To: <200705191408.44138.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivo van Doorn <ivdoorn@gmail.com>
Date: Sat, 19 May 2007 14:08:43 +0200

> coverity has spotted a bug in rfkill.c (bug id #1627),
> in rfkill_allocate() NULL was returns if the kzalloc() works,
> and deref the NULL pointer if it fails,
> 
> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

I really wonder how well tested this rfkill code is
if the object allocation is so busted like this :-/

I'll apply your patch, thank you.
