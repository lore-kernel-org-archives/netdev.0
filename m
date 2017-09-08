From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Thu, 07 Sep 2017 21:27:19 -0600
Message-ID: <375ef875d9c8744f344891bf06b8dd61@codeaurora.org>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <20170907.191324.852949594923852324.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55210 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbdIHD1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 23:27:20 -0400
In-Reply-To: <20170907.191324.852949594923852324.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> [ 3489.194392]  __ion_alloc+0x180/0x988
> 
> I do not see the __ion_alloc function in my tree.

Hi David

This function seems to be defined in an Android specific change.

https://android.googlesource.com/kernel/msm/+/20a5411d0115b16826f3d327b6abb0192c8a2001

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
