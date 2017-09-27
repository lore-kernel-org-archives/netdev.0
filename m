From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 6/6] net: dsa: mv88e6xxx: Flood broadcast frames
 in hardware
Date: Wed, 27 Sep 2017 12:33:29 -0700
Message-ID: <465be6d8-67d0-d176-1252-abb222bf0528@gmail.com>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
 <1506464764-12699-7-git-send-email-andrew@lunn.ch>
 <8737786lua.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <9733da02-0b69-33f0-de8a-63bc5cae6bb4@gmail.com>
 <20170927184636.GD12394@lunn.ch>
 <8760c4t0df.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:53114 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750739AbdI0Tdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 15:33:35 -0400
Received: by mail-qk0-f174.google.com with SMTP id o77so14396974qke.9
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 12:33:34 -0700 (PDT)
In-Reply-To: <8760c4t0df.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2017 12:19 PM, Vivien Didelot wrote:
> Hi Andrew, Florian,
> 
> Andrew Lunn <andrew@lunn.ch> writes:
> 
>> It took me a while to make this work with CONFIG_BRIDGE_VLAN_FILTERING
>> enabled. Any change to enable hardware flooding needs careful testing
>> for lots of different configurations. This is another reason i don't
>> want to do it at the DSA level, until we have a good understanding
>> what it means in each individual driver.
> 
> Then if we are worried about how broadcast flooding is handled on
> different switches, we can provide a new .flood_broadcast(ds, vid)
> switch operation for the drivers to implement.

We don't really have a good visibility on the number of switches
requiring special configuration for broadcast addresses nor how this
would have to happen so it would be a tad difficult to define an
appropriate API with a single user.

In general, single user "generic" facilities tend to be biased towards
their particular problem space (c.f: devlink) so a generic interface to
call into HW specific details does not usually sell well...
-- 
Florian
