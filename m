From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/hsr: Added support for HSR v1
Date: Tue, 19 Apr 2016 12:12:27 -0400 (EDT)
Message-ID: <20160419.121227.1437003570791513649.davem@davemloft.net>
References: <20160413115222.GA42572@aircraft-controller>
	<20160419082100.237f1b6e@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mail@pheise.de, arvid.brodin@alten.se, hannes@stressinduktion.org,
	sd@queasysnail.net, henrik@austad.us, nikolay@cumulusnetworks.com,
	tgraf@suug.ch, linville@tuxdriver.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, eranbe@mellanox.com, ast@plumgrid.com,
	netdev@vger.kernel.org, peter.heise@airbus.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933276AbcDSQMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:12:31 -0400
In-Reply-To: <20160419082100.237f1b6e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 19 Apr 2016 08:21:00 -0700

> On Wed, 13 Apr 2016 13:52:22 +0200
> Peter Heise <mail@pheise.de> wrote:
> 
>> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> index 9427f17..bb3a90b 100644
>> --- a/include/uapi/linux/if_link.h
>> +++ b/include/uapi/linux/if_link.h
>> @@ -773,6 +773,7 @@ enum {
>>  	IFLA_HSR_SLAVE1,
>>  	IFLA_HSR_SLAVE2,
>>  	IFLA_HSR_MULTICAST_SPEC,	/* Last byte of supervision addr */
>> +	IFLA_HSR_VERSION,		/* HSR version */
>>  	IFLA_HSR_SUPERVISION_ADDR,	/* Supervision frame multicast addr */
>>  	IFLA_HSR_SEQ_NR,
> 
> You added a new value into the middle of an enumeration field.
> This breaks kernel ABI. Older applications (like iproute) would see the wrong
> values.
> 
> Please submit a new change which moves HSR_VERSION to the end of the enum

Good catch, Stephen.
