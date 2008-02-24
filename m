From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO
 selection based on L4 ports
Date: Sun, 24 Feb 2008 00:01:14 -0500
Message-ID: <47C0FA1A.6090505@garzik.org>
References: <47BCA6C5.1070805@trash.net>	<78C9135A3D2ECE4B8162EBDCE82CAD77030E30E5@nekter>	<47BCB304.9050709@trash.net> <20080220.151244.79005114.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, Ramkrishna.Vepa@neterion.com,
	Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org,
	support@neterion.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51962 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750726AbYBXFBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 00:01:20 -0500
In-Reply-To: <20080220.151244.79005114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 21 Feb 2008 00:08:52 +0100
> 
>> Ramkrishna Vepa wrote:
>>>> Sreenivasa Honnur wrote:
>>>>     
>>>>> - Resubmit #2
>>>>> - Transmit fifo selection based on TCP/UDP ports.
>>>>> - Added tx_steering_type loadable parameter for transmit fifo
>>>>>       
>>> selection.
>>>   
>>>>>   0x0 NO_STEERING: Default FIFO is selected.
>>>>>   0x1 TX_PRIORITY_STEERING: FIFO is selected based on skb->priority.
>>>>>   0x2 TX_DEFAULT_STEERING: FIFO is selected based on L4 Ports.
>>>>>
>>>>>       
>>>> Why duplicate the generic multiqueue classification?
>>>>     
>>> [Ram] Could you be more specific?
>>>   
>> The generic multiqueue support classifies packets by setting
>> skb->queue_mapping using qdisc classifiers, which is more
>> flexible and avoids using module parameters.
> 
> But it doesn't do what these multiqueue TX queue hardware devices
> want.  These devices don't want packet scheduler "classification",
> they want load balancing using some key (current cpu number,
> hashing on the packet headers, etc.)  And that's not what our
> packet scheduler classifiers do or should do.
> 
> We don't want to have to tell people "you have to run 'tc' magic
> foo to use all of the TX queues on your network card."  That's
> completely unreasonable and stupid.
> 
> We have to resolve this somehow, and there have been many discussions
> about this a month or so ago.

So where does that leave this patch?  :)

	Jeff




