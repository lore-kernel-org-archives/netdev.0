From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional for
 dsa2
Date: Fri, 6 Jan 2017 14:47:38 -0800
Message-ID: <0dbf9730-2409-30f9-e9e4-946fe7fec413@gmail.com>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
 <20170106222008.GC10626@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <uwe@kleine-koenig.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32938 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939962AbdAFWrl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 17:47:41 -0500
In-Reply-To: <20170106222008.GC10626@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2017 02:20 PM, Andrew Lunn wrote:
>> If one wants to rename an interface, udev rules can be used as usual.
> 
> Hi Vivien
> 
> Do you have some examples?
> 
> A quick look at udevadm info suggests we can use
> 
> ATTR{phys_port_id} and ATTR{phys_switch_id}
> 
> Humm, it would be nice to know why the second switch has a
> phys_switch_id of 01000000.

Well, that's a combination of being on a little endian system and using
%*phN as a printk formatter, and the type being 32-bit long (int). I
agree this does not feel natural, but since this is sysfs (so ABI in a
way), it's going to be though to change now.
-- 
Florian
