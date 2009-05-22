From: Chaitanya Lala <clala@riverbed.com>
Subject: Re: [net-next-2.6 PATCH 1/1] e1000e: Expose MDI-X status via	ethtool
 change
Date: Fri, 22 May 2009 08:24:25 -0700
Message-ID: <4A16C3A9.3070402@riverbed.com>
References: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>	 <20090522145544.GA8508@clala-laptop> <1243004704.3192.21.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:59020 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbZEVPXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 11:23:49 -0400
In-Reply-To: <1243004704.3192.21.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Fri, 2009-05-22 at 07:55 -0700, Chaitanya Lala wrote:
>   
>> Ethtool is a standard way of getting information about ethernet
>> interfaces. We enhance ethtool kernel interface & e1000e to make
>> the MDI-X status readable via ethtool in userspace.
>>     
> [...] 
>   
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index 380b042..0533d70 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -26,6 +26,7 @@ struct ethtool_cmd {
>>  	__u8	phy_address;
>>  	__u8	transceiver;	/* Which transceiver to use */
>>  	__u8	autoneg;	/* Enable or disable autonegotiation */
>> +	__u8	is_mdix;	/* MDI-X status tri-state value */
>>  	__u8	mdio_support;
>>     
> [...]
>
> There's no gap here, so this would move all the following fields and
> break all older ethtool clients.
>
> Ben.
>
>   
Then should I move it to the bottom ?

Chaitanya

