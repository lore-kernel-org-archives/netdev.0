From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 08:33:11 -0700 (PDT)
Message-ID: <20151021.083311.2193871332944250588.davem@davemloft.net>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
	<5587575.y3COavlu1k@wuerfel>
	<5627A792.3020201@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5627A792.3020201@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 21 Oct 2015 07:56:18 -0700

>> @@ -57,6 +57,11 @@ extern int of_dma_get_range(struct device_node *np,
>> u64 *dma_addr,
>>   				u64 *paddr, u64 *size);
>>   extern bool of_dma_is_coherent(struct device_node *np);
>>   #else /* CONFIG_OF_ADDRESS */
>> +static inline u64 of_translate_address(struct device_node *np, const
>> __be32 *addr)
>> +{
>> +	return 0;
> 
> Maybe return OF_BAD_ADDR ?

The thing to really do on sparc, is just return the address raw untranslated
because that just works.
