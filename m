From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] bnx2: Don't receive packets when the napi
 budget == 0
Date: Tue, 11 Mar 2014 22:07:35 -0700
Message-ID: <1394600855.21721.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	 <20140311.124907.1180556684992271103.davem@davemloft.net>
	 <87wqg0cy9d.fsf@xmission.com>
	 <20140311.160931.1395978386605601765.davem@davemloft.net>
	 <877g808luk.fsf_-_@xmission.com> <871ty88lsy.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56335 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbaCLFHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 01:07:37 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so568425pad.28
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 22:07:37 -0700 (PDT)
In-Reply-To: <871ty88lsy.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 14:31 -0700, Eric W. Biederman wrote:
> Processing any incoming packets with a with a napi budget of 0
> is incorrect driver behavior.
> 
> This matters as netpoll will shortly call drivers with a budget of 0
> to avoid receive packet processing happening in hard irq context.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
