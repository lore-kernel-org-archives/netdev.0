From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] dsa: remove unused net_device arg from handlers
Date: Thu, 17 Aug 2017 11:53:56 -0700
Message-ID: <74dc3b77-67b9-286b-edbd-acec6cba3694@gmail.com>
References: <20170817144700.16218-1-fw@strlen.de>
 <20170817182116.GE21715@lunn.ch> <20170817184058.GA7154@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com
To: Florian Westphal <fw@strlen.de>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34780 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753230AbdHQSyB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 14:54:01 -0400
Received: by mail-wr0-f195.google.com with SMTP id p14so1243783wrg.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 11:54:00 -0700 (PDT)
In-Reply-To: <20170817184058.GA7154@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 11:40 AM, Florian Westphal wrote:
> Andrew Lunn <andrew@lunn.ch> wrote:
>> On Thu, Aug 17, 2017 at 04:47:00PM +0200, Florian Westphal wrote:
>>> compile tested only, but saw no warnings/errors with
>>> allmodconfig build.
>>>  
>>>  static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
>>> -			  struct packet_type *pt, struct net_device *orig_dev)
>>> +			  struct packet_type *pt, struct net_device *unused)
>>
>> Hi Florian
>>
>> Looks O.K. to me. I can test it out later.
>>
>> Is there a bigger picture here? Do you plan to remove the second
>> net_device parameter everywhere?
> 
> Its tempting, seems only af_packet uses it.  I'll see if there is
> another (simpler) way of getting the orig ifindex into af_packet.
> 

FWIW, I still have some changes queued locally that make use of orig_dev
to support the switch tag HW insertion/extraction, but I think "dev"
here is equally suitable since it still points to the DSA master network
device.
-- 
Florian
