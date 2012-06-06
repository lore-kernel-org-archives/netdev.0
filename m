From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 22:31:25 +0200
Message-ID: <1339014685.26966.73.camel@edumazet-glaptop>
References: <jqo7op$t6f$1@dough.gmane.org>
	 <20120606.115130.1091814494251887552.davem@davemloft.net>
	 <jqo9ej$ao4$1@dough.gmane.org>
	 <20120606.131703.870120997635192180.davem@davemloft.net>
	 <jqoe90$fs3$2@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Edwards <grant.b.edwards@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:65034 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757418Ab2FFUb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 16:31:28 -0400
Received: by eaak11 with SMTP id k11so2110538eaa.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 13:31:27 -0700 (PDT)
In-Reply-To: <jqoe90$fs3$2@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 20:24 +0000, Grant Edwards wrote:

> Is skb_tailroom() guaranteed to be >= the requested size?
> 

Of course, but only right after alloc_skb().
