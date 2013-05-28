From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v5 net-next 1/5] net: add napi_id and hash
Date: Tue, 28 May 2013 11:03:05 +0300
Message-ID: <51A464B9.5080106@linux.intel.com>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>  <20130527074401.29882.98135.stgit@ladj378.jer.intel.com> <1369700905.3301.499.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369700905.3301.499.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/05/2013 03:28, Eric Dumazet wrote:
> On Mon, 2013-05-27 at 10:44 +0300, Eliezer Tamir wrote:
>> +extern void napi_hash_add(struct napi_struct *napi);
>> +
>> +/**
>> + *	napi_hash_del - remove a NAPI from blobal table
>
> global

Thank you
(my typing is almost as bad as my spelling, please don't tell my mom)

>> @@ -166,6 +167,10 @@ static struct list_head offload_base __read_mostly;
>>   DEFINE_RWLOCK(dev_base_lock);
>>   EXPORT_SYMBOL(dev_base_lock);
>>
>> +atomic_t napi_gen_id;
>
> Not sure we need an atomic, we are protected by RTNL anyway.

With an atomic we don't need the RTNL in any of the napi_id functions.
One less thing to worry about when we try to remove the RTNL.

-Eliezer
