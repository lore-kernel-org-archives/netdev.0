From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] 8139cp: Don't receive packets when the
 napi budget == 0
Date: Tue, 11 Mar 2014 22:08:10 -0700
Message-ID: <1394600890.21721.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	 <20140311.124907.1180556684992271103.davem@davemloft.net>
	 <87wqg0cy9d.fsf@xmission.com>
	 <20140311.160931.1395978386605601765.davem@davemloft.net>
	 <877g808luk.fsf_-_@xmission.com> <87vbvk777k.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:46818 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaCLFIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 01:08:12 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so566106pbb.8
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 22:08:11 -0700 (PDT)
In-Reply-To: <87vbvk777k.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 14:31 -0700, Eric W. Biederman wrote:
> Processing any incoming packets with a with a napi budget of 0
> is incorrect driver behavior.
> 
> This matters as netpoll will shortly call drivers with a budget of 0
> to avoid receive packet processing happening in hard irq context.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com
> ---
>  drivers/net/ethernet/realtek/8139cp.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
