From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Sat, 29 Aug 2015 08:20:43 -0700
Message-ID: <55E1CDCB.2030205@cumulusnetworks.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
 <1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150828.221417.905062374709400810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36819 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047AbbH2PUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 11:20:44 -0400
Received: by padhm10 with SMTP id hm10so36406100pad.3
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 08:20:43 -0700 (PDT)
In-Reply-To: <20150828.221417.905062374709400810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/28/15 10:14 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 28 Aug 2015 18:31:07 -0700
>
>> On Fri, 2015-08-28 at 17:34 -0700, David Ahern wrote:
>>> Currently the VRF driver registers an Rx handler for enslaved devices.
>>> The handler switches the skb->dev to the VRF device and sends it back for
>>> another pass. While this works fine a side effect is that it bypasses
>>> netfilter with the skb set to the original device.
>>>
>>
>> Arg ... yet another hook in packet processing fast path...
>>
>> What are long term plans for VRF ? Will it stay VRF-Lite or what ?
>
> +1
>

Cumulus Networks is invested in the VRF solution, and we will be here 
for the long haul. We want a feature complete, performant and stable 
solution for open networking. My preference is for a built-in solution 
rather than a bolted on one and I am trying to do that by engaging the 
community and getting feedback early for decisions and preferences.

As for the details, I am finishing IPv4 integration now. Basic VRF-lite 
situations work great and I have tested a few IPsec and MPLS setups as 
well. I have one more patch to address Tom's comment regarding 
udp_sendmsg; I need to verify it works for fragmentation and I'll push 
it out. After that I will start on IPv6 next week.

David
