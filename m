From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/8] netfilter: xt_time gives a wrong monthday in a
 leap year
Date: Mon, 22 Sep 2008 19:03:50 -0700 (PDT)
Message-ID: <20080922.190350.63489376.davem@davemloft.net>
References: <200809222150.m8MLoaXW031860@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaih.luo@gmail.com,
	jengelh@computergmbh.de, kaber@trash.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49795
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753885AbYIWCEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:04:02 -0400
In-Reply-To: <200809222150.m8MLoaXW031860@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Mon, 22 Sep 2008 14:50:36 -0700

> From: Kaihui Luo <kaih.luo@gmail.com>
> 
> The function localtime_3 in xt_time.c gives a wrong monthday in a leap
> year after 28th 2.  calculating monthday should use the array
> days_since_leapyear[] not days_since_year[] in a leap year.
> 
> Signed-off-by: Kaihui Luo <kaih.luo@gmail.com>
> Acked-by: Jan Engelhardt <jengelh@computergmbh.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Patrick, this seems pretty straightforward so I applied it
to net-next-2.6
