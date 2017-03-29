From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: dsa: dsa2: Add basic support of devlink
Date: Wed, 29 Mar 2017 10:29:07 -0700
Message-ID: <c844a885-cfd3-4358-89dd-c619d3d394e4@gmail.com>
References: <1490737507-7864-1-git-send-email-andrew@lunn.ch>
 <1490737507-7864-3-git-send-email-andrew@lunn.ch>
 <2fe7ffc9-1bf1-537a-e361-33156a6f5a07@gmail.com>
 <20170329013112.GF3152@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, sfrench@samba.org,
        linux-cifs@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35885 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751717AbdC2R3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 13:29:12 -0400
In-Reply-To: <20170329013112.GF3152@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2017 06:31 PM, Andrew Lunn wrote:
> On Tue, Mar 28, 2017 at 05:33:18PM -0700, Florian Fainelli wrote:
>> On 03/28/2017 02:45 PM, Andrew Lunn wrote:
>>> Register the switch and its ports with devlink.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>
>> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
>> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
>>
>> root@net-vm:~# devlink -p port
>> mdio_bus/fixed-0:1f/0: type eth netdev lan1
>> mdio_bus/fixed-0:1f/1: type eth netdev lan2
>> mdio_bus/fixed-0:1f/2: type eth netdev lan3
>> mdio_bus/fixed-0:1f/3: type eth netdev lan4
>> mdio_bus/fixed-0:1f/5: type notset
>> root@net-vm:~# devlink -p dev
>> mdio_bus/fixed-0:1f
> 
> Thanks Florian
> 
> I have another patch somewhere which adds new types for CPU and DSA
> ports. Once these 2 patches have landed, and the reports of broken
> builds stop, i will dig it out.
> 
> But my main priority at the moment is to play with dpipe and make sure
> it can represent tables we have in DSA switches, before the Binary API
> is frozen.

Yes, that is a very good point actually.

Tangential question: we do not currently report to user space what kind
of switch tagging protocol is used (DSA, eDSA etc.) I was going to add a
sysfs attribute for that under the switch device's directory, but maybe
devlink would be more appropriate for that?
-- 
Florian
