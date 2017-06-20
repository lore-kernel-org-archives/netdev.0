From: John Crispin <john@phrozen.org>
Subject: Re: [RFC 1/2] net-next: fix DSA flow_disection
Date: Tue, 20 Jun 2017 19:38:53 +0200
Message-ID: <229f981f-8e01-8ca9-e90e-573f2761ba8e@phrozen.org>
References: <20170620080655.7251-1-john@phrozen.org>
 <20170620140140.GB12383@lunn.ch>
 <ec46025d-4618-499c-72fe-693da9abc050@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:54369 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbdFTRjN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 13:39:13 -0400
In-Reply-To: <ec46025d-4618-499c-72fe-693da9abc050@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 20/06/17 19:30, Florian Fainelli wrote:
> On 06/20/2017 07:01 AM, Andrew Lunn wrote:
>> On Tue, Jun 20, 2017 at 10:06:54AM +0200, John Crispin wrote:
>>> RPS and probably other kernel features are currently broken on some if not
>>> all DSA devices. The root cause of this that skb_hash will call the
>>> flow_disector.
>> Hi John
>>
>> What is the call path when the flow_disector is called? I'm wondering
>> if we can defer this, and call it later, after the tag code has
>> removed the header.
> Would not you usually want to configure RPS at the DSA network device
> level where the switch tag has already been popped and you are
> processing a regular Ethernet frame at that point?
Hi Florian,

is explained in my mail to Andrew, you really want to be able to setup 
RPS for all devices in the chain to free up the core handling IRQs

     John
