From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ipv6: rearm router solicitaion timer when setting
 new tokenized address
Date: Wed, 26 Jun 2013 19:16:45 +0200
Message-ID: <51CB21FD.3060602@redhat.com>
References: <20130626014149.GB20081@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893Ab3FZRQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 13:16:52 -0400
In-Reply-To: <20130626014149.GB20081@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2013 03:41 AM, Hannes Frederic Sowa wrote:
> When a new tokenized address gets installed we send out just one
> router solicition. We should send out `rtr_solicits' in case one router
> advertisment got lost.
>
> So, rearm the timer as we do in addrconf_dad_complete.
>
> Cc: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
