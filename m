From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next] net: ipv6: Add early demux handler for UDP
 unicast
Date: Wed, 08 Mar 2017 12:11:43 -0700
Message-ID: <8b6968063320eb8ddc654f79d3461f21@codeaurora.org>
References: <1488997457-24554-1-git-send-email-subashab@codeaurora.org>
 <1488998446.28631.13.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42160 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752094AbdCHTOS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:14:18 -0500
In-Reply-To: <1488998446.28631.13.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-08 11:40, Eric Dumazet wrote:
> Well, this 'optimization' actually hurts when UDP sockets are not
> connected, since this adds an extra cache line miss per incoming 
> packet.
> 
> (DNS servers for example)

Hi Eric

Thanks for your comments. Would it be preferable to disable early demux 
for the
servers with large unconnected workloads in that case?

> 
>> 
>> Signed-off-by: Subash Abhinov Kasiviswanathan 
>> <subashab@codeaurora.org>
>> ---
> 
>> +
>> +	if (dst)
>> +		dst = dst_check(dst, 0);
> 
> 
> IPv6 uses a cookie to validate dst, not 0.

I'll update this and send v2.
