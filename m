From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cassini: i reaches 0, not -1.
Date: Mon, 09 Feb 2009 17:56:00 -0800 (PST)
Message-ID: <20090209.175600.191087624.davem@davemloft.net>
References: <4990AA32.1010004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40356
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbZBJB4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 20:56:07 -0500
In-Reply-To: <4990AA32.1010004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 09 Feb 2009 23:12:02 +0100

> With while (i-- > 0) { ... } i reaches 0, not -1.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Does it?

--------------------
#include <stdio.h>
int main(void)
{
	int i = 20;
	while (i-- > 0)
		;
	printf("%d\n", i);

	return 0;
}
--------------------
davem@sunset:~/src/GIT/linux-2.6$ gcc -O2 -o x x.c
davem@sunset:~/src/GIT/linux-2.6$ ./x
-1
davem@sunset:~/src/GIT/linux-2.6$ 
