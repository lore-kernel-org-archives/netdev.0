From: Jason Wang <jasowang@redhat.com>
Subject: Re: surprising memory request
Date: Mon, 21 Jan 2013 13:23:24 +0800
Message-ID: <50FCD0CC.2010009@redhat.com>
References: <20130118085818.147220.FMU5901@air.gr8dns.org>  <1358531190.11051.402.camel@edumazet-glaptop> <1358531946.2397.265.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dirk Hohndel <dirk@hohndel.org>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915Ab3AUFXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 00:23:32 -0500
In-Reply-To: <1358531946.2397.265.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2013 01:59 AM, David Woodhouse wrote:
> On Fri, 2013-01-18 at 09:46 -0800, Eric Dumazet wrote:
>> #define MAX_TAP_QUEUES 1024
>>
>> Thats crazy if your machine has say 8 cpus.
> Even crazier if your userspace is never going to *use* MQ. Can't we
> default to one queue unless userspace explicitly requests more?
>

Yes, if userspace never use MQ, we just use a one queue netdevice. Just
draft a patch fro Dirk to test.

Thanks
