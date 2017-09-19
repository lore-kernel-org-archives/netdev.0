From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: move master ethtool code
Date: Tue, 19 Sep 2017 16:04:38 -0700 (PDT)
Message-ID: <20170919.160438.114096071481057977.davem@davemloft.net>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
        <80b8afa0-e269-c0b7-da4a-dcb604a239ca@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <80b8afa0-e269-c0b7-da4a-dcb604a239ca@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 19 Sep 2017 13:04:56 -0700

> On 09/19/2017 08:56 AM, Vivien Didelot wrote:
>> The DSA core overrides the master device's ethtool_ops structure so that
>> it can inject statistics and such of its dedicated switch CPU port.
>> 
>> This ethtool code is currently called on unnecessary conditions or
>> before the master interface and its switch CPU port get wired up.
>> This patchset fixes this.
>> 
>> Similarly to slave.c where the DSA slave net_device is the entry point
>> of the dsa_slave_* functions, this patchset also isolates the master's
>> ethtool code in a new master.c file, where the DSA master net_device is
>> the entry point of the dsa_master_* functions.
>> 
>> This is a first step towards better control of the master device and
>> support for multiple CPU ports.
> 
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> * ethtool -S eth0 -> switch port CPU stats are still correctly overlayed
> * ethtool -s gphy wol g -> both switch port and CPU port correctly
> enable WoL
> * ethtool -i eth0 -> driver still reports correct information

Series applied, thanks everyone.
