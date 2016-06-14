From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next v2 09/12] net: dsa: mv88e6xxx: add SMI detection helper
Date: Tue, 14 Jun 2016 18:10:53 -0400
Message-ID: <877fdr1kwi.fsf@ketchup.mtl.sfl>
References: <20160614183153.32327-1-vivien.didelot@savoirfairelinux.com> <20160614183153.32327-10-vivien.didelot@savoirfairelinux.com> <20160614215034.GH12832@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160614215034.GH12832@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

>> -	name = info->name;
>> +	dev_info(dev, "switch 0x%x detected: %s, revision %u\n", prod_num,
>> +		 info->name, rev);
>>  
>> -	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
>> +	ps = devm_kzalloc(dev, sizeof(*ps), GFP_KERNEL);
>>  	if (!ps)
>>  		return NULL;
>
> I don't like the way this detect function goes a lot further than
> detection. I would say detection finished when you have the info
> structure. Return at that point, and let the probe do the rest.

OK, I split detection and allocation.

Thanks,

        Vivien
