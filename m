From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] bonding: add more ethtool support
Date: Sat, 13 Sep 2008 21:17:30 -0400
Message-ID: <48CC662A.6060100@pobox.com>
References: <20080811113416.178e7446@extreme> <10549.1218841133@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42651 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202AbYINBRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 21:17:38 -0400
In-Reply-To: <10549.1218841133@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Stephen Hemminger <stephen.hemminger@vyatta.com> wrote:
> 
>> This patch allows reporting the link, checksum, and feature settings
>> of bonded device by using generic hooks.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> --- a/drivers/net/bonding/bond_main.c	2008-08-11 11:22:42.000000000 -0700
>> +++ b/drivers/net/bonding/bond_main.c	2008-08-11 11:26:07.000000000 -0700
>> @@ -4493,6 +4493,12 @@ static void bond_ethtool_get_drvinfo(str
>>
>> static const struct ethtool_ops bond_ethtool_ops = {
>> 	.get_drvinfo		= bond_ethtool_get_drvinfo,
>> +	.get_link		= ethtool_op_get_link,
>> +	.get_tx_csum		= ethtool_op_get_tx_csum,
>> +	.get_sg			= ethtool_op_get_sg,
>> +	.get_tso		= ethtool_op_get_tso,
>> +	.get_ufo		= ethtool_op_get_ufo,
>> +	.get_flags		= ethtool_op_get_flags,
>> };
>>
>> /*
> 
> 	Jeff, please apply.
> 
> Acked-by: Jay Vosburgh <fubar@us.ibm.com>

applied


