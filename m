From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [Patch]net/xfrm/xfrm_policy.c: replace timer with delayed_work
Date: Thu, 1 May 2008 00:06:55 +0800 (CST)
Message-ID: <alpine.LFD.1.10.0804302355120.2940@localhost.localdomain>
References: <20080216.235534.237382205.xiyou.wangcong@gmail.com> <20080427011809.GA662@gondor.apana.org.au> <20080428.225312.58450957.xiyou.wangcong@gmail.com> <20080428151342.GA12007@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: WANG Cong <xiyou.wangcong@gmail.com>, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@osdl.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:35966 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761953AbYD3QC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 12:02:57 -0400
Received: by py-out-1112.google.com with SMTP id u52so906834pyb.10
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 09:02:55 -0700 (PDT)
In-Reply-To: <20080428151342.GA12007@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Apr 2008, Herbert Xu wrote:

> On Mon, Apr 28, 2008 at 10:53:12PM +0800, WANG Cong wrote:
>>
>> Do you mean ->lock of struct xfrm_policy?
>> OK. I will recook these two patches soon.
>
> Yep.

Hi, Herbert.

I referenced the book Linux Device Drivers, it is said that
the work function in workqueue can sleep, that is to say, it only
works in process context, so we don't need the disable the lock
in softirq, which is interrupt context, right?

Please teach me if I missed some obvious things. ;-)

Thanks.

