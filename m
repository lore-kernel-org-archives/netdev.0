From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] Revert "rtnetlink: check DO_SETLINK_NOTIFY correctly
 in do_setlink"
Date: Thu, 26 Oct 2017 09:22:06 -0600
Message-ID: <8e16702b-1b63-327b-a085-b57c322e91dc@gmail.com>
References: <47e8fd3f-fa47-0e3b-1041-b931c64aa45b@6wind.com>
 <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        vyasevic@redhat.com, Xin Long <lucien.xin@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50385 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932127AbdJZPWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:22:06 -0400
Received: by mail-pf0-f196.google.com with SMTP id b6so2742490pfh.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:22:06 -0700 (PDT)
In-Reply-To: <20171026082153.8042-1-nicolas.dichtel@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 2:21 AM, Nicolas Dichtel wrote:
> This reverts commit 64ff90cc2e6f42596d7a0c37e41dc95292bb63b1.
> 
> The initial test was right. The goal is to advertised any modifications of
> any setting of a link. The test ensures that the user won't lose an update.
> 
> CC: David Ahern <dsahern@gmail.com>
> CC: Xin Long <lucien.xin@gmail.com>
> Reported-by: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

To be explicit based on the followup comments, Dave, please drop this patch.
