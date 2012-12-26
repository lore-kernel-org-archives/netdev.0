From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] ndisc: Ensure to reserve header space for
 encapsulation.
Date: Wed, 26 Dec 2012 11:21:33 -0800
Message-ID: <1356549693.20133.20875.camel@edumazet-glaptop>
References: <50D9BAA4.7000207@linux-ipv6.org>
	 <1356540521.20133.20554.camel@edumazet-glaptop>
	 <50DB4B3D.2050800@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:47310 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab2LZTVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 14:21:35 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so5071022pad.33
        for <netdev@vger.kernel.org>; Wed, 26 Dec 2012 11:21:35 -0800 (PST)
In-Reply-To: <50DB4B3D.2050800@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-27 at 04:08 +0900, YOSHIFUJI Hideaki wrote:

> Current code does not make sense, at least.
> 
> Please refer to my previous posting: "[GIT PULL net-next 01/17]
> ndisc: Fix size calculation for headers." around Dec/19.
> 
> My previous patch did remove MAX_HEADER from allocation.

Yes, but the changelog was misleading, and David misunderstood it.

If you really explain why its safe to remove MAX_HEADER, I think
your patch would make sense.
