From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/3] net: dsa: assign switch device in legacy code
Date: Sat, 05 Aug 2017 16:09:28 -0400
Message-ID: <873795g4jr.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170804222320.10986-1-vivien.didelot@savoirfairelinux.com> <20170804222320.10986-2-vivien.didelot@savoirfairelinux.com> <20170805005526.GA19193@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805005526.GA19193@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> @@ -251,8 +251,9 @@ dsa_switch_setup(struct dsa_switch_tree *dst, struct net_device *master,
>>  	ds->cd = cd;
>>  	ds->ops = ops;
>>  	ds->priv = priv;
>> +	ds->dev = parent;
>
> Is this even needed? dsa_switch_alloc() does ds->dev = dev.

You are correct! Respinning.


Thanks,

        Vivien
