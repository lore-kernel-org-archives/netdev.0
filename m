From: Ben Greear <greearb@candelatech.com>
Subject: Re: data received but not detected
Date: Tue, 17 Jun 2008 15:31:19 -0700
Message-ID: <48583B37.5070708@candelatech.com>
References: <1213740538.5771.192.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Travis Stratman <tstratman@emacinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:42947 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbYFQWbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 18:31:31 -0400
In-Reply-To: <1213740538.5771.192.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Travis Stratman wrote:
> Hello,
> 
> (I sent this earlier today but it doesn't look like it made it, I
> apologize if it gets through multiple times)
> 
> I am working on an application that uses a fairly simple UDP protocol to
> send data between two embedded devices. I'm noticing an issue with an
> initial test that was written where datagrams are received but not seen
> by the recvfrom() call until more data arrives after it. As of right now
> the test case does not implement any type of lost packet protection or
> other flow control, which is what makes the issue so noticeable.

UDP packets can be lost anywhere..including in the receive buffer
after it has been received by the NIC.

You probably just need to write your code smarter to use non-blocking
IO and deal with packet loss.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

