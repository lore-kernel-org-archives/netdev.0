From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next 4/4] net: qualcomm: rmnet: Add support for GRO
Date: Wed, 25 Oct 2017 12:00:18 -0600
Message-ID: <b557f39a42f86307eb580b7c02fe8a0e@codeaurora.org>
References: <1508907329-1077-1-git-send-email-subashab@codeaurora.org>
 <1508907329-1077-5-git-send-email-subashab@codeaurora.org>
 <1508940057.30291.122.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43112 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932124AbdJYSAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 14:00:19 -0400
In-Reply-To: <1508940057.30291.122.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You need to check return code and abort if memory could not be
> allocated.
> 
> There is a reason this helper has _init() prefix, it does not belong to
> _setup() since a _setup() is not expected to fail.
> 
> Please take a look at other gro_cells_init() callers, and you will
> notice that it is called from ndo_init()
> 
> You might have copied the only buggy caller (vxlan).
> 
> Tom, if you read me fix vxlan, thanks !

Hi Eric

Thanks for pointing this out. I'll change this in v2.

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
a Linux Foundation Collaborative Project
