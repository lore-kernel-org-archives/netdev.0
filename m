From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] af_packet: Add Queue mapping mode to af_packet fanout
 operation
Date: Thu, 23 Jan 2014 08:56:21 +0100
Message-ID: <52E0CB25.2040803@redhat.com>
References: <1390424504-18543-1-git-send-email-nhorman@tuxdriver.com>  <52E03F80.8020803@redhat.com> <1390439292.27806.48.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751635AbaAWH4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 02:56:34 -0500
In-Reply-To: <1390439292.27806.48.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

n 01/23/2014 02:08 AM, Eric Dumazet wrote:
> On Wed, 2014-01-22 at 23:00 +0100, Daniel Borkmann wrote:
>> On 01/22/2014 10:01 PM, Neil Horman wrote:
>>> This patch adds a queue mapping mode to the fanout operation of af_packet
>>> sockets.  This allows user space af_packet users to better filter on flows
>>> ingressing and egressing via a specific hardware queue, and avoids the potential
>>
>> Maybe I'm missing something, but I currently cannot find where this is
>> being filled out for ingress path? Egress, ok, this gets filled out
>> somewhere in protocol layers or elsewhere and is being locally pushed
>> back through dev_queue_xmit_nit(), but I think main use case is ingress
>> through packet fanout. In driver layer I can find skb->rxhash filled out
>> which would then be PACKET_FANOUT_HASH.
>> (Otherwise patch looks good.)
>
> Check for various multiqueue drivers calling skb_record_rx_queue()

Okay, thanks for the clarification Eric, patch looks good then.
