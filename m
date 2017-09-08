From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Thu, 07 Sep 2017 19:33:48 -0600
Message-ID: <dec03f40984321f51ed1c357ab3b756a@codeaurora.org>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <20170908025620.47d0ad2e@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, lorenzo@google.com
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35774 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbdIHBdt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 21:33:49 -0400
In-Reply-To: <20170908025620.47d0ad2e@elisabeth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Should be fixed by:
> 
> commit ad65a2f05695aced349e308193c6e2a6b1d87112
> Author: Wei Wang <weiwan@google.com>
> Date:   Sat Jun 17 10:42:35 2017 -0700
> 
>     ipv6: call dst_hold_safe() properly
> 

Thanks for the info Stefano.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
