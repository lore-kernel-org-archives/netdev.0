From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix a lockdep splat
Date: Wed, 3 Feb 2016 09:39:17 +0100
Message-ID: <56B1BCB5.6040601@stressinduktion.org>
References: <20160202195933.GA6302@codemonkey.org.uk>
 <1454464501.7627.210.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:36602 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968AbcBCIjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:39:21 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 5A1DF206E6
	for <netdev@vger.kernel.org>; Wed,  3 Feb 2016 03:39:20 -0500 (EST)
In-Reply-To: <1454464501.7627.210.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.02.2016 02:55, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Silence lockdep false positive about rcu_dereference() being
> used in the wrong context.
>
> First one should use rcu_dereference_protected() as we own the spinlock.
 >
> Second one should be a normal assignation, as no barrier is needed.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
