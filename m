From: John Crispin <john@phrozen.org>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Wed, 21 Jun 2017 06:33:25 +0200
Message-ID: <e6570fed-3a8b-4d1b-ce0f-857ff000638a@phrozen.org>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620140140.GB12383@lunn.ch>
 <390b4235-1bd4-89d2-3a5f-bc51e3599247@phrozen.org>
 <20170620215230.GG12383@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:35331 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdFUEdc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 00:33:32 -0400
In-Reply-To: <20170620215230.GG12383@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/06/17 23:52, Andrew Lunn wrote:
>> On Tue, Jun 20, 2017 at 07:37:35PM +0200, John Crispin wrote:
>>
>>
>> On 20/06/17 16:01, Andrew Lunn wrote:
>>> On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
>>>> RPS and probably other kernel features are currently broken on some if not
>>>> all DSA devices. The root cause of this that skb_hash will call the
>>>> flow_disector.
>>> Hi John
>>>
>>> What is the call path when the flow_disector is called? I'm wondering
>>> if we can defer this, and call it later, after the tag code has
>>> removed the header.
>>>
>>> 	Andrew
> Hi John
>
> I follow your logic of doing the hash early
>
> Is there any value in including the DSA header in the hash? That might
> allow frames from different ingress ports to be spread over CPUs?
>
>        Andrew
Hi Andrew,

adding the DSA header wont make any difference and would still require a 
patch to the flow dissector.

     John
