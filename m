From: Ben Greear <greearb@candelatech.com>
Subject: Re: data received but not detected
Date: Tue, 17 Jun 2008 16:45:49 -0700
Message-ID: <48584CAD.6010509@candelatech.com>
References: <1213740538.5771.192.camel@localhost.localdomain>	 <48583B37.5070708@candelatech.com> <1213743506.5771.220.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:55291 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756052AbYFQXqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:46:14 -0400
In-Reply-To: <1213743506.5771.220.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Travis Stratman wrote:
> On Tue, 2008-06-17 at 15:31 -0700, Ben Greear wrote:
>> Travis Stratman wrote:
>>> I am working on an application that uses a fairly simple UDP protocol to
>>> send data between two embedded devices. I'm noticing an issue with an
>>> initial test that was written where datagrams are received but not seen
>>> by the recvfrom() call until more data arrives after it. As of right now
>>> the test case does not implement any type of lost packet protection or
>>> other flow control, which is what makes the issue so noticeable.
>> UDP packets can be lost anywhere..including in the receive buffer
>> after it has been received by the NIC.
>>
>> You probably just need to write your code smarter to use non-blocking
>> IO and deal with packet loss.
> 
> Thanks Ben.
> 
> I understand that there is no guarantee of anything with UDP, but it
> seems to me that if there is a packet in the buffer (it shows up after
> another packet comes in behind it) the system should know about it,
> right?

Ahh, I see what you mean.

I'm afraid I don't know anything about your NIC driver, and it would
seem to be implicated.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

