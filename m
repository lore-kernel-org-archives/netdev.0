From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: remove redundant test on unsigned
Date: Tue, 23 Jun 2009 04:30:05 -0700 (PDT)
Message-ID: <20090623.043005.190546452.davem@davemloft.net>
References: <4A3FC178.7050505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752401AbZFWLaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 07:30:01 -0400
In-Reply-To: <4A3FC178.7050505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Mon, 22 Jun 2009 19:38:00 +0200

> Unsigned boguscnt cannot be less than 0.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

To be honest since this never possibly triggered, it never
provided any help diagnosing any problem, so removing the
test altogether is likely best.

I'll integrate this once -rc1 is out and it's OK for 2.6.32
bound stuff to start showing up in linux-next.

Thanks!
