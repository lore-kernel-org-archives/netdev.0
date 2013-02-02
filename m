From: Steve Muckle <smuckle@codeaurora.org>
Subject: Re: invalid socket structure with ip_early_demux
Date: Fri, 01 Feb 2013 18:27:47 -0800
Message-ID: <510C79A3.1020607@codeaurora.org>
References: <510C752F.5010102@codeaurora.org>  <1359771370.30177.50.camel@edumazet-glaptop> <1359771917.30177.52.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1359771917.30177.52.camel@edumazet-glaptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/13 18:25, Eric Dumazet wrote:
> A fix would be to add after :
> 
> sk = skb->sk;
> 
> the following code :
> 
> if (sk && sk->sk_state == TCP_TIME_WAIT)
> 	sk = NULL;

Thanks. I assumed the xt_qtaguid code was ok because xt_owner does a
similar thing - does that also need this fix?

-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation
