From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 02/13] net-caif: add CAIF header files
Date: Fri, 22 Jan 2010 12:05:18 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079032320E2@eseldmw101.eemea.ericsson.se>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com><1264028130-14364-3-git-send-email-sjur.brandeland@stericsson.com> <20100120152739.31aacc08.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<marcel@holtmann.org>, <stefano.babic@babic.homelinux.org>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:64518 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909Ab0AVLFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 06:05:22 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20100120152739.31aacc08.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Randy.
Randy Dunlap wrote:
> Just a couple of nits here (below):
>> +++ b/include/linux/caif/caif_config.h
> ...
>> +struct caif_channel_config {
>> +	char name[16];
>> +	enum caif_channel_type type;
>> +	unsigned priority;
>> +	enum caif_phy_preference phy_pref;
>> +	char phy_name[16];
>> +
>> +	/** Union of channel type-specific configuration parameters.
> 
> Don't use /** here.
OK,
> 
>> +
>> +/**
>> + * struct ifcaif_param - Parameters for creating CAIF Network
>> Interface. + * + * When using SIOCCAIFNETNEW to create a CAIF IP
>> interface, this +structure + * is used for configuration data.
>> + * The attribute ifr_ifru.ifru_data in struct struct ifreq must be
>> +set + * point at an instance of struct ifcaif_param.
>> + *
>> + * @ipv4_connid:  Connection ID for IPv4 PDP Context.
>> + * @ipv6_connid:  Connection ID for IPv6 PDP Context.
>> + * @loop:	  If different from zero, device is doing loopback + */
>> +struct ifcaif_param {
>> +	__u32			ipv4_connid;
>> +	__u32			ipv6_connid;
>> +	__u8			loop;
>> +};
>> +
>> +/**
>> + * enum ifla_caif
> 
> Above line needs " - <short description>" on it.
Sure, I'll add that - thanks.
> 

BR/Sjur
