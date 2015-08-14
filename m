From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 1/2] Add a matching set of device_ functions for
 determining mac/phy
Date: Fri, 14 Aug 2015 10:55:53 -0500
Message-ID: <55CE0F89.2040200@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
 <1439417187-21411-2-git-send-email-jeremy.linton@arm.com>
 <55CBC524.4070101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: "steve.glendinning@shawell.net" <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rafael.j.wysocki@intel.com" <rafael.j.wysocki@intel.com>,
	"suravee.suthikulpanit@amd.com" <suravee.suthikulpanit@amd.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:20239 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755204AbbHNP4A convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 11:56:00 -0400
In-Reply-To: <55CBC524.4070101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2015 05:13 PM, Florian Fainelli wrote:
> On 12/08/15 15:06, Jeremy Linton wrote:
>> +
>> +static void *device_get_mac_addr(struct device *dev,
>> +				 const char *name, char *addr,
>> +				 int alen)
>> +{
>> +	int ret = device_property_read_u8_array(dev, name, addr, alen);
>> +
>> +	if (ret == 0 && is_valid_ether_addr(addr))
>> +		return addr;
>> +	return NULL;
>
> The DT counterpart has an additional check on the properly length to be
> ETH_ALEN, you might want to have such check here for consistency and
> correctness.

I will add it back,

Thanks,
