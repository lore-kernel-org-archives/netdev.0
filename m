From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Sun, 05 Oct 2014 18:18:47 -0700
Message-ID: <5431EDF7.3080201@gmail.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006002951.GA24376@breakpoint.cc> <20141005.210938.412085917241295226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, dborkman@redhat.com, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:37689 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaJFBTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:19:06 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so3186013obc.15
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 18:19:05 -0700 (PDT)
In-Reply-To: <20141005.210938.412085917241295226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2014 06:09 PM, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 6 Oct 2014 02:29:51 +0200
>
>> John Fastabend <john.fastabend@gmail.com> wrote:
>>> There is one critical difference when running with these interfaces
>>> vs running without them. In the normal case the af_packet module
>>> uses a standard descriptor format exported by the af_packet user
>>> space headers. In this model because we are working directly with
>>> driver queues the descriptor format maps to the descriptor format
>>> used by the device. User space applications can learn device
>>> information from the socket option PACKET_DEV_DESC_INFO which
>>> should provide enough details to extrapulate the descriptor formats.
>>> Although this adds some complexity to user space it removes the
>>> requirement to copy descriptor fields around.
>>
>> I find it very disappointing that we seem to have to expose such
>> hardware specific details to userspace via hw-independent interface.
>>
>> How big of a cost are we talking about when you say that it 'removes
>> the requirement to copy descriptor fields'?
>
> FWIW, it also avoids the domain switch (which is just a fancy way
> to refer to performing the system call), both in and out.
>

Right, my description could have been better and called this out.

Thanks.

-- 
John Fastabend         Intel Corporation
