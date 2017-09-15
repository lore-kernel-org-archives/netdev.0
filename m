From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 15 Sep 2017 17:20:11 -0600
Message-ID: <0b4e9dbc852c4df7401dc770f357ae6a@codeaurora.org>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>
 <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com>
 <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.20.1709160103190.1770@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40118 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdIOXUT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 19:20:19 -0400
In-Reply-To: <alpine.LFD.2.20.1709160103190.1770@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 	May be I'm missing some posting but I don't see if
> the patch was tested successfully.
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>

Hi Julian

I've had this patch being tested for the last 3-4 days in our regression 
rack
and I haven't seen the same issue being reproduced or even a related 
crash
or leak in dst.
The original issue was reported only once to us from the regression rack 
only
so the exact steps to reproduce is unknown.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
