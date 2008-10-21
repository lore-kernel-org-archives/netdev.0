From: Terry <hanfang@baidu.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 20:34:03 +0800
Message-ID: <48FDCC3B.6020806@baidu.com>
References: <20081020190922.7dd6510a@extreme>	<48FD6E8A.6060304@cosmosbay.com>	<18685.37380.34636.316536@robur.slu.se>	<48FD97AB.1040007@baidu.com> <18685.51303.285228.177350@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.baidu.com ([61.135.163.61]:41606 "HELO smtp.baidu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753121AbYJUMeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 08:34:06 -0400
In-Reply-To: <18685.51303.285228.177350@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Robert Olsson wrote:
> Terry writes:
>  > Hi 
>  >     yeah. In the forwarding scenario , skb recycling should boost the 
>  > performance by avoiding slowpath slub alloc/free .But if  using 
>  > multiqueue hardware and assigning proper  cpu affinities  could  make it 
>  > always in the fastpath of slub  alloc/free, which is faster?
>
>  For perfect setup with monotone work like forwarding you can make the skb 
>  recycling a little faster.
>
>  If you have many active NIC's and the recycling list is per device the situation
>  it's probably different...
>
>  Cheers.
> 						--ro
>   

Yeah,it's different. So I am considering X-NICs  skb recycling like the 
"global" recycler you mentioned.It may help. But it may introduce some 
race-conditions too.

Rgds.

Terry

