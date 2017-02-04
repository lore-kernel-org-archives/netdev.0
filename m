From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/6] net: dsa: simplify netdevice events handling
Date: Sat, 04 Feb 2017 11:13:19 -0500
Message-ID: <87d1eyorxc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com> <20170203182021.14246-3-vivien.didelot@savoirfairelinux.com> <ddcb0439-73f1-fe66-cacb-ab01f2146fe2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ddcb0439-73f1-fe66-cacb-ab01f2146fe2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>> -	if (dsa_slave_dev_check(dev))
>> -		return dsa_slave_port_event(dev, event, ptr);
>> +	if (dev->netdev_ops != &dsa_slave_netdev_ops)
>> +		return NOTIFY_DONE;
>
> Why not keep the dsa_slave_dev_check() here?

I dropped it because that condition feels more readable to me than
!dsa_slave_dev_check(dev).

Thanks,

        Vivien
