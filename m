From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6 not bringing up due to qdisc_tx_is_noop failing
Date: Wed, 16 Mar 2016 18:07:44 +0100
Message-ID: <56E992E0.1080708@stressinduktion.org>
References: <56E97BEA.4070004@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	SiteGround Operations <operations@siteground.com>
To: Nikolay Borisov <kernel@kyup.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46552 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932322AbcCPRHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:07:47 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 4C24B20D4B
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 13:07:46 -0400 (EDT)
In-Reply-To: <56E97BEA.4070004@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 16.03.2016 16:29, Nikolay Borisov wrote:
> I have stack traces which do show this sequence of events, so my
> questions now are:
>
> 1. What's the difference between netdev_queue->qdisc and
> netdev_queue->qdisc_sleeping. Git blaming indicates those member haves
> existed even before the git history was started.

qdisc_sleeping is the qdisc you configure before the device is brought 
up. It should transition during carrier up to the normal qdisc.

> 2. Shouldn't the netdev_queue->qdisc also be updated during
> attach_one_default_qdisc?

Yes, do you have carrier up on your card?

Is this a regression, did this work for you and stopped working with a 
specific kernel version?

Thanks and bye,
Hannes
