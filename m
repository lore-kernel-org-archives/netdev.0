From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Convert do_gettimeofday() to getnstimeofday().
Date: Mon, 21 Apr 2008 02:34:23 -0700 (PDT)
Message-ID: <20080421.023423.01701534.davem@davemloft.net>
References: <20080421.162221.11408096.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60887
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751157AbYDUJeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 05:34:21 -0400
In-Reply-To: <20080421.162221.11408096.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 21 Apr 2008 16:22:21 +0900 (JST)

> What do_gettimeofday() does is to call getnstimeofday() and
> to convert the result from timespec{} to timeval{}.
> After that, these callers convert the result again to msec.
> Use getnstimeofday() and convert the units at once.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This looks straightforward, applied, thanks.
