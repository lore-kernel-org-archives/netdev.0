From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with
 MSG_CONFIRM.
Date: Thu, 13 Sep 2007 01:12:05 -0700 (PDT)
Message-ID: <20070913.011205.74725606.davem@davemloft.net>
References: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
	<20070913.093528.54061581.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:50782
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752805AbXIMIMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 04:12:09 -0400
In-Reply-To: <20070913.093528.54061581.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 13 Sep 2007 09:35:28 +0900 (JST)

> | [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with MSG_CONFIRM.
> 
> Ah, I should say, socket locking, probably...
> Anyway, lock_sock() and release_sock() are not paired approriately.

Thanks for these fixes, I'll merge these in as soon as I
can, which might take a little bit since I'm traveling today.
