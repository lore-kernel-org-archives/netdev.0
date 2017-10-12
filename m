From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 4/5] net: dsa: add slave get master helper
Date: Thu, 12 Oct 2017 19:23:34 -0400
Message-ID: <87o9pc6jd5.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171012225156.20758-1-vivien.didelot@savoirfairelinux.com> <20171012225156.20758-5-vivien.didelot@savoirfairelinux.com> <e3e7001e-8618-0b31-cd28-ebcdad561f7b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e3e7001e-8618-0b31-cd28-ebcdad561f7b@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 10/12/2017 03:51 PM, Vivien Didelot wrote:
>> Many part of the DSA slave code require to get the master device
>> assigned to a slave device. Remove dsa_master_netdev() in favor of a
>> dsa_slave_get_master() helper which does that.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
>> ---
>
>> +static inline struct net_device *
>> +dsa_slave_get_master(const struct net_device *dev)
>> +{
>> +	struct dsa_port *dp = dsa_slave_to_port(dev);
>> +
>> +	return dp->cpu_dp->netdev;
>> +}
>
> Nit: _get may convey the idea that a reference count may be incremented
> when the function is called (balanced with a _put), so maybe name it
> dsa_slave_to_master() which is more in line with dsa_slave_to_port() as
> well? Other than that:
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Perfect, I was hesitating myself between the two, but I didn't have a
good argument for any of them. Now I have one! I'll change that for
dsa_slave_to_master and add your tag.


Thanks,

        Vivien
