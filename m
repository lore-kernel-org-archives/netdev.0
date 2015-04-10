From: Ben Greear <greearb@candelatech.com>
Subject: Re: EACCES sending UDP to broadcast address?
Date: Thu, 09 Apr 2015 18:14:39 -0700
Message-ID: <552723FF.40705@candelatech.com>
References: <552721AC.9080900@candelatech.com> <1428628362.25985.284.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51825 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbDJBOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 21:14:40 -0400
In-Reply-To: <1428628362.25985.284.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/2015 06:12 PM, Eric Dumazet wrote:
> On Thu, 2015-04-09 at 18:04 -0700, Ben Greear wrote:
>> I'm running as root user, 4.0-rc6 + hack kernel.
>>
>> User-space app is (or should be) trying to send a UDP frame
>> to 255.255.255.255 destination.
>>
>> I am getting EACCESS from sendmmsg.
>>
>> Is this expected?  Is there something even more special than root these
>> days?
> 
> man 7 socket
> 
>        SO_BROADCAST
>               Set  or  get  the  broadcast flag.  When enabled, datagram
> sockets are allowed to send packets to a broadcast address.  This option
> has no effect on stream-oriented
>               sockets.
> 
> 
> 
> root user still has to use this option.


Thanks, I'll go do that.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
