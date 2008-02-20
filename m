From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support - FIFO
 selection based on L4 ports
Date: Thu, 21 Feb 2008 00:08:52 +0100
Message-ID: <47BCB304.9050709@trash.net>
References: <Pine.GSO.4.10.10802201644130.11320-100000@guinness> <47BCA6C5.1070805@trash.net> <78C9135A3D2ECE4B8162EBDCE82CAD77030E30E5@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	netdev@vger.kernel.org, jeff@garzik.org,
	support <support@neterion.com>
To: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62685 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbYBTXJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:09:05 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77030E30E5@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa wrote:
>> Sreenivasa Honnur wrote:
>>     
>>> - Resubmit #2
>>> - Transmit fifo selection based on TCP/UDP ports.
>>> - Added tx_steering_type loadable parameter for transmit fifo
>>>       
> selection.
>   
>>>   0x0 NO_STEERING: Default FIFO is selected.
>>>   0x1 TX_PRIORITY_STEERING: FIFO is selected based on skb->priority.
>>>   0x2 TX_DEFAULT_STEERING: FIFO is selected based on L4 Ports.
>>>
>>>       
>> Why duplicate the generic multiqueue classification?
>>     
> [Ram] Could you be more specific?
>   

The generic multiqueue support classifies packets by setting
skb->queue_mapping using qdisc classifiers, which is more
flexible and avoids using module parameters.


