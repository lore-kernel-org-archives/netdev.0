From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: limit reaches -1, but 0 tested
Date: Sun, 01 Feb 2009 01:59:31 -0800 (PST)
Message-ID: <20090201.015931.127677783.davem@davemloft.net>
References: <4984473C.1040508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752430AbZBAJ7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2009 04:59:34 -0500
In-Reply-To: <4984473C.1040508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 31 Jan 2009 13:42:36 +0100

> With a postfix decrement these reach -1 rather than 0,
> but after the loop it is tested to have become 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Just like the case just pointed out in your 'net' version
of this patch, it is being tested "<= 0" so this fix
is not necessary at all.

Please carefully review all of your changes of this kind
to make sure the test is strictly equality to zero rather
than <= 0.

I'm dropping all of these postfix decrement patches.
