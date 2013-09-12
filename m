From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/4] bridge: Don't use VID 0 and 4095 in vlan filtering
Date: Thu, 12 Sep 2013 16:57:31 -0400
Message-ID: <52322ABB.9050903@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita> <1378809144.3988.6.camel@ubuntu-vm-makita> <522F2B22.5010007@redhat.com> <20130912.155533.521690436399073964.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590Ab3ILU5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 16:57:37 -0400
In-Reply-To: <20130912.155533.521690436399073964.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2013 03:55 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Tue, 10 Sep 2013 10:22:26 -0400
>
>> On 09/10/2013 06:32 AM, Toshiaki Makita wrote:
>>> IEEE 802.1Q says that:
>>> - VID 0 shall not be configured as a PVID, or configured in any
>>> - Filtering
>>> Database entry.
>>> - VID 4095 shall not be configured as a PVID, or transmitted in a tag
>>> header. This VID value may be used to indicate a wildcard match for
>>> the VID
>>> in management operations or Filtering Database entries.
>>> (See IEEE 802.1Q-2005 6.7.1 and Table 9-2)
>>>
>>> Don't accept adding these VIDs in the vlan_filtering implementation.
>>>
>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>
>> Reviewed-by: Vlad Yasevich <vyasevich@redhat.com>
>
> Vlad, as far as I can see your redhat.com email ends just with a "c"
> not a "ch".  It's your gmail account that ends in a "ch".
>
> I'm fixing this up while applying these patches, if you have something
> automatically generating these reviewed-by strings please fix it up
> although I note that some are correct and some are not so maybe you
> do this by hand :-)
>

Apologies.  Yes, I usually ack things by hand and sometimes fingers just
keep going...

-vlad
