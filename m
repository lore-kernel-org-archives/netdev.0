From: Daniel Slot <slot.daniel@gmail.com>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Wed, 12 Aug 2009 21:27:17 +0200
Message-ID: <bb6e06c00908121227y7f215c15yd8d4748de9059d3@mail.gmail.com>
References: <bb6e06c00908121150q6d08cdfdp818c26cd8ae4f064@mail.gmail.com>
	 <20090812120204.2e13163e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:29991 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbZHLT1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 15:27:17 -0400
Received: by ey-out-2122.google.com with SMTP id 22so26825eye.37
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2009 12:27:17 -0700 (PDT)
In-Reply-To: <20090812120204.2e13163e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I already tried to adapt the style to existing code.
Would be nice if you could give me hint about what is akward.
I'm quite new to the kernelhacking area and sorry for all obvious errors.

The usage is imho interesting in research domains.
As it is an implementation of an ietf RFC, there might be some
researchers who can use it.
It is part of my master thesis and I use it for measurements and comparisons.

I tried to avoid a sysctl value for this.
I don't wanted this algorithm to be used by all TCP connections.

2009/8/12 Stephen Hemminger <shemminger@vyatta.com>:
> On Wed, 12 Aug 2009 20:50:59 +0200
> Daniel Slot <slot.daniel@gmail.com> wrote:
>
>> RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
>> In the absence of explicit congestion notification from the network,
>> TCP uses loss as an indication of congestion.
>> One of the ways TCP detects loss is using the arrival of three
>> duplicate acknowledgments.
>> However, this heuristic is not always correct, notably in the case
>> when network paths reorder segments (for whatever reason), resulting
>> in degraded performance.
>> TCP-NCR is designed to mitigate this degraded performance by
>> increasing the number of duplicate acknowledgments required to trigger
>> loss recovery,
>> based on the current state of the connection, in an effort to better
>> disambiguate true segment loss from segment reordering.
>> This document specifies the changes to TCP, as well as the costs and
>> benefits of these modifications.
>>
>> This patch adds TCP-NCR as socket option to the Linux kernel (version 2.6.30.4).
>> Written by Daniel Slot, Email: slot.daniel(at)gmail.com
>
> Patch has funny indentation and awkward naming for socket elements.
> Your style needs to match existing code.
>
> What is the usage model for this? I expect that some user who wants
> to enable this would be stuck somewhere with a lossy network and
> would want to enable it. Or is it something only researchers will
> want to play with?
>
> It would be easier to use a sysctl value for this because otherwise
> each application has to be changed to select the socket option.
>
> --
>
