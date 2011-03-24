From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] tc : SFB flow scheduler
Date: Thu, 24 Mar 2011 14:59:51 -0700
Message-ID: <20110324145951.153b0059@nehalam>
References: <1298390536.2861.9.camel@edumazet-laptop>
	<1298474091.3301.364.camel@edumazet-laptop>
	<1298494577.2898.9.camel@edumazet-laptop>
	<20110223.140614.112607341.davem@davemloft.net>
	<1298526035.2898.20.camel@edumazet-laptop>
	<20110223225143.30226902@nehalam>
	<1300988649.3747.160.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Juliusz.Chroboczek@pps.jussieu.fr, netdev <netdev@vger.kernel.org>,
	Jonathan Morton <chromatix99@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50527 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756417Ab1CXV7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 17:59:53 -0400
In-Reply-To: <1300988649.3747.160.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Mar 2011 18:44:09 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
> 
> Supports SFB qdisc (included in linux-2.6.39)
> 
> 1) Setup phase : accept non default parameters
> 
> 2) dump information 
> 
> qdisc sfb 11: parent 1:11 limit 1 max 25 target 20
>   increment 0.00050 decrement 0.00005 penalty rate 10 burst 20 (600000ms 60000ms)
>  Sent 47991616 bytes 521648 pkt (dropped 549245, overlimits 549245 requeues 0) 
>  rate 7193Kbit 9774pps backlog 0b 0p requeues 0 
>   earlydrop 0 penaltydrop 0 bucketdrop 0 queuedrop 549245 childdrop 0 marked 0
>   maxqlen 0 maxprob 0.00000 avgprob 0.00000 
> 
> Signed-off-by: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied (to net-next branch)


-- 
