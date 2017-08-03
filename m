From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/13] phylink and sfp support
Date: Thu, 3 Aug 2017 11:11:54 -0700
Message-ID: <b4ed6c0c-1472-283a-5535-773b59891ac0@gmail.com>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
 <20170801143933.GI23157@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35399 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdHCSL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 14:11:59 -0400
Received: by mail-wm0-f52.google.com with SMTP id m85so1900547wma.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 11:11:59 -0700 (PDT)
In-Reply-To: <20170801143933.GI23157@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2017 07:39 AM, Andrew Lunn wrote:
> On Tue, Jul 25, 2017 at 03:01:39PM +0100, Russell King - ARM Linux wrote:
>> Hi,
>>
>> This patch series introduces generic support for SFP sockets found on
>> various Marvell based platforms.  The idea here is to provide common
>> SFP socket support which can be re-used by network drivers as
>> appropriate, rather than each network driver having to re-implement
>> SFP socket support.
> 
> There is a lot of code here, and i'm not really going to understand it
> until i use it. I have a couple of boards with SFFs connected to
> switches, so i will spend some time over the next month or so to make
> DSA use phylink. As is usual, we can sort out any issues as we go
> along.
> 
> David, if it still applies cleanly, can you add it to net-next?

Agreed, this is in a good shape and the more people we can have testing
this, the better. It may be nice to include a consumer of the PHYLINK
API for other people to start copying from.
-- 
Florian
