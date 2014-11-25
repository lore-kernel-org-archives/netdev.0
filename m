From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH rfc 1/4] net-timestamp: pull headers for SOCK_STREAM
Date: Tue, 25 Nov 2014 14:54:34 -0500 (EST)
Message-ID: <20141125.145434.1790615963499624322.davem@davemloft.net>
References: <1416938286-14147-2-git-send-email-willemb@google.com>
	<20141125.134240.861582393401487675.davem@davemloft.net>
	<CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, luto@amacapital.net,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaKYTyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:54:37 -0500
In-Reply-To: <CA+FuTSdT9=Hi7K3OnMxVRiK8PmS4=DvVqLumWx74OEz3okx23A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 25 Nov 2014 14:52:00 -0500

> On Tue, Nov 25, 2014 at 1:42 PM, David Miller <davem@davemloft.net> wrote:
>> From: Willem de Bruijn <willemb@google.com>
>> Date: Tue, 25 Nov 2014 12:58:03 -0500
>>
>> What's the harm in exposing the headers?  Either it's harmful, and
>> therefore doing so for UDP is bad too, or it's harmless and
> 
> Headers may expose information not available otherwise. I don't
> immediately see critical problems, but that does not mean that they
> might not lurk there.
> 
> We so far avoid exposing the sequence number, though keeping it hidden
> is more about third parties. More in general, unprivileged processes
> may start requesting timestamps only to learn tcp state that they
> should either get from tcpinfo or cannot currently get at all, likely
> for good reason. A far-fetched example is identifying admin iptables
> tos mangling rules by reading the tos bits at the driver layer. At least
> on my machine, iptables -L is privileged.
> 
>> we should probably leave it alone to not risk breaking anyone.
> 
> That's fair. I sent it for rfc first for that reason. I won't resubmit
> unless more serious concerns are raised.

I just worry about the potential breakage.

Your concerns are valid... I honestly don't know what we should do here.
Both choices have merit.
