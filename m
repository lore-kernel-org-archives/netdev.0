From: Thomas Klein <osstklei@de.ibm.com>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Sat, 12 Aug 2006 18:37:04 +0200
Message-ID: <44DE03B0.1060607@de.ibm.com>
References: <44D99F38.8010306@de.ibm.com> <20060811215225.GH479@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:27333 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S964881AbWHLQhG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:37:06 -0400
To: Anton Blanchard <anton@samba.org>,
	Jan-Bernd Themann <themann@de.ibm.com>
In-Reply-To: <20060811215225.GH479@krispykreme>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> Hi,
>
>   
>> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea_ethtool.c	1969-12-31 
>>     
>
>   
>> +static void netdev_get_pauseparam(struct net_device *dev,
>> +				  struct ethtool_pauseparam *pauseparam)
>> +{
>> +	printk("get pauseparam\n");
>> +}
>>     
>
> There are a number of stubbed out ethtool functions like this. Best not
> to implement them and allow the upper layers to return a correct error.
>
> Anton
>   
I agree, stubbs were removed.

Thomas

