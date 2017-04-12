From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: add CONFIG_NET_DSA_LEGACY
Date: Wed, 12 Apr 2017 10:50:17 -0400
Message-ID: <87shldznme.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170411205237.29309-1-vivien.didelot@savoirfairelinux.com> <20170411212026.GA7023@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170411212026.GA7023@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> +#ifdef CONFIG_NET_DSA_LEGACY
>>  static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
>>  				       struct device *host_dev, int sw_addr,
>>  				       void **priv)
>> @@ -4256,6 +4257,7 @@ static const char *mv88e6xxx_drv_probe(struct device *dsa_dev,
>>  
>>  	return NULL;
>>  }
>> +#endif /* CONFIG_NET_DSA_LEGACY */
>
> Rather than scatter #ifdef everywhere, can you use
>
>        if (!IS_ENABLED(CONFIG_NET_DSA_LEGACY))
>               return NULL
>
> The compiler will then throw away the rest of the function, after
> checking it does actually compile.

I'll make the legacy code compile anyway then.

Thanks!

        Vivien
