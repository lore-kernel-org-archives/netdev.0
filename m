From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 1/8] net: dsa: Allow switch drivers to indicate
 number of RX/TX queues
Date: Thu, 31 Aug 2017 21:00:43 -0700
Message-ID: <8a530e4c-1932-dcbb-1eaf-fc4c849c5e3f@gmail.com>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <1504138732-65383-2-git-send-email-f.fainelli@gmail.com>
 <20170831234412.GA28960@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, jhs@mojatatu.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35490 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdIAEAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 00:00:47 -0400
Received: by mail-oi0-f44.google.com with SMTP id n18so8978110oig.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 21:00:47 -0700 (PDT)
In-Reply-To: <20170831234412.GA28960@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/31/2017 04:44 PM, Andrew Lunn wrote:
> On Wed, Aug 30, 2017 at 05:18:45PM -0700, Florian Fainelli wrote:
>> Let switch drivers indicate how many RX and TX queues they support. Some
>> switches, such as Broadcom Starfighter 2 are resigned with 8 egress
>> queues.
> 
> Marvell switches also have egress queue.
> 
> Does the SF2 have ingress queues? Marvel don't as far as i known.  So
> i wounder if num_rx_queues is useful?

At the moment probably not, since we are not doing anything useful other
than creating the network devices with the indicated number of queues.

> 
> Do switches in general have ingress queues? 

They do, at least the Starfigther 2 has, and from the Broadcom tag you
can get such information (BRCM_EG_TC_SHIFT) and you could presumably
record that queue on the SKB. I don't have an use case for that (yet?).
-- 
Florian
