From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add support of Cavium Liquidio ethernet adapters
Date: Mon, 24 Nov 2014 16:08:37 -0500 (EST)
Message-ID: <20141124.160837.1008717214755094566.davem@davemloft.net>
References: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<54739C92.5070309@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rvatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750792AbaKXVIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 16:08:41 -0500
In-Reply-To: <54739C92.5070309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 24 Nov 2014 13:01:06 -0800

> On 11/23/2014 07:19 PM, Raghu Vatsavayi wrote:
>> +if LIQUIDIO
>> +
>> +config LIQUIDIO_NAPI
>> +	bool "Enable NAPI for LiquidIO"
>> +	default y
>> +	---help---
>> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
>> +	  when the driver is receiving lots of packets from the card. You
>> +	  would only disable this feature in very specific instances, like
>> +	  an application that very rapidly sets up and tears down connections.
>> +
>> +	  If in doubt, say Y.
> 
> You probably do not want to offer a non-NAPI variant, pretty much all
> drivers have NAPI built-in now.

+1.

>> +config LIQUIDIO_DEBUG
>> +	int "Debug level for LiquidIO"
>> +	range 0 4
>> +	default 0
> 
> This should be moved to dynamic_debug/ethtools' msglvl control knob.

+1
