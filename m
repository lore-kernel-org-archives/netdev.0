From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net] tcp-repair: Handle zero-length data put in rcv queue
Date: Sat, 03 Nov 2012 20:15:09 +0400
Message-ID: <5095430D.4090703@parallels.com>
References: <508E9B3D.1050505@parallels.com> <20121102.220211.734003528595209418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gmavrikas@gmail.com" <gmavrikas@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29432 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198Ab2KCQPX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 12:15:23 -0400
In-Reply-To: <20121102.220211.734003528595209418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2012 06:02 AM, David Miller wrote:
> From: Pavel Emelyanov <xemul@parallels.com>
> Date: Mon, 29 Oct 2012 19:05:33 +0400
> 
>> When sending data into a tcp socket in repair state we should check
>> for the amount of data being 0 explicitly. Otherwise we'll have an skb 
>> with seq == end_seq in rcv queue, but tcp doesn't expect this to happen
>> (in particular a warn_on in tcp_recvmsg shoots).
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>> Reported-by: Giorgos Mavrikas <gmavrikas@gmail.com>
> 
> Applied, thanks.
> 
>> From 8f70f4ea4f509a3772ee7eb5d9d5c2571a86652a Mon Sep 17 00:00:00 2001
>> From: Pavel Emelyanov <xemul@parallels.com>
>> Date: Mon, 29 Oct 2012 18:12:41 +0400
>> Subject: [PATCH] fix for repair queue getback
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> What is this?

It's a garbage left after patches rebase and resplit. Sorry for that :(

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
