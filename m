From: David Miller <davem@davemloft.net>
Subject: Re: Small glitch in neptune ethernet driver
Date: Fri, 02 Dec 2011 12:37:43 -0500 (EST)
Message-ID: <20111202.123743.248340759104432882.davem@davemloft.net>
References: <4EA845CF.6070401@intra2net.com>
	<20111201.220003.905428158537118068.davem@davemloft.net>
	<201112020949.32369.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.jarosch@intra2net.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170Ab1LBRht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 12:37:49 -0500
In-Reply-To: <201112020949.32369.thomas.jarosch@intra2net.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Date: Fri, 2 Dec 2011 09:49:32 +0100

> On Friday, 2. December 2011 04:00:03 David Miller wrote:
>> diff --git a/drivers/net/ethernet/sun/niu.c
>> b/drivers/net/ethernet/sun/niu.c index 680b107..56d106e 100644
>> --- a/drivers/net/ethernet/sun/niu.c
>> +++ b/drivers/net/ethernet/sun/niu.c
>> @@ -8579,9 +8579,11 @@ static int __devinit phy_record(struct niu_parent
>> *parent, if (dev_id_1 < 0 || dev_id_2 < 0)
>>  		return 0;
>>  	if (type == PHY_TYPE_PMA_PMD || type == PHY_TYPE_PCS) {
>> +		/* Becuase of the NIU_PHY_ID_MASK being applied, the 8704
> 
> The change looks good to me, just fix the typo in "Becuase".

Fixed, thanks.
