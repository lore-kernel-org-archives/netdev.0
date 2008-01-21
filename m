From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 17:15:15 -0600
Message-ID: <47952783.8080505@nortel.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com> <47950A71.5010304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:62465 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041AbYAUXP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 18:15:26 -0500
In-Reply-To: <47950A71.5010304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Chris Friesen wrote:
> 
>> Is there anything else we can do to minimize the latency of network 
>> packet processing and avoid having to crank the rx ring size up so high?
> 
> 
> Why is it such a big deal to crank up the rx queue length?  Seems like
> a perfectly normal way to handle bursts like this...

It means that the latency for handling those packets is higher than it 
could be.  Draining 4096 packets from the queue will take a while.

Ideally we'd like to bring the latency down as much as possible, and 
then bump up the rx queue length to handle the rest.

Chris
