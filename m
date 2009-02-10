From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: ticks reaches 25, not 26.
Date: Mon, 09 Feb 2009 17:57:14 -0800 (PST)
Message-ID: <20090209.175714.70463534.davem@davemloft.net>
References: <4990AC93.3080906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56675
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752445AbZBJB5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 20:57:20 -0500
In-Reply-To: <4990AC93.3080906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 09 Feb 2009 23:22:11 +0100

> With while (tick++ < 25) { ... } ticks reaches 25, not 26.

Does it?

--------------------
#include <stdio.h>
int main(void)
{
	int i = 0;
	while (i++ < 25)
		;
	printf("%d\n", i);

	return 0;
}
--------------------
davem@sunset:~/src/GIT/linux-2.6$ gcc -O2 -o x x.c
davem@sunset:~/src/GIT/linux-2.6$ ./x
26
davem@sunset:~/src/GIT/linux-2.6$ 

I'm getting extremely tired of these "off by one" patches, to be
honest with you.
