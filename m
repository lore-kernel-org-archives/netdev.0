From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] tulip: hardware mitigation simplify
Date: Mon, 11 Feb 2008 10:43:06 -0500
Message-ID: <47B06D0A.9040007@pobox.com>
References: <20071213093554.5c4909ed@freepuppy.rosehill> <47B06AE3.4020809@DunveganMedia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristjan <kristjan.ugrin@gmail.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39974 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256AbYBKPnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 10:43:13 -0500
In-Reply-To: <47B06AE3.4020809@DunveganMedia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Stephen Hemminger wrote:
>> The hardware mitigation in tulip can be simpified.
>> 1. The budget with new NAPI will always be less than RX_RING_SIZE
>>    because RX_RING_SIZE is 128 and weight is 16.
>> 2. The received counter is redundunt, just use the work_done value.
>> 3. Only one value is used from the mit_table[]
>>
>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

grrr.  Mozilla Thunderbird is annoying.

Please help me out, and --don't-- reply to jgarzik@dunveganmedia.com. 
T-bird's multi-profile stuff is fouling me up.

Sorry :(

	Jeff


