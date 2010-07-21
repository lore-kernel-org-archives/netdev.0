From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 23:34:57 -0700 (PDT)
Message-ID: <20100720.233457.267367495.davem@davemloft.net>
References: <20100720141816.16f0a939@nehalam>
	<20100720.142045.32697196.davem@davemloft.net>
	<4C469313.6010807@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bhutchings@solarflare.com,
	sassmann@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gospo@redhat.com,
	gregory.v.rose@intel.com, alexander.h.duyck@intel.com,
	leedom@chelsio.com
To: harald@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C469313.6010807@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Harald Hoyer <harald@redhat.com>
Date: Wed, 21 Jul 2010 08:26:27 +0200

> On 07/20/2010 11:20 PM, David Miller wrote:
>> From: Stephen Hemminger<shemminger@vyatta.com>
>> Date: Tue, 20 Jul 2010 14:18:16 -0700
>>
>>> No one mentioned that the first octet of an Ethernet address already
>>> indicates "software generated" Ethernet address. Per the standard,
>>> if bit 1 is set it means address is locally assigned.
>>>
>>> static inline bool is_locally_assigned_ether(const u8 *addr)
>>> {
>>> 	return (addr[0]&  0x2) != 0;
>>> }
>>
>> W00t!
>>
>> Indeed, can udev just use that?  :-)
> 
> It already does:
> see /lib/udev/rules.d/75-persistent-net-generator.rules

So... why doesn't this work?
