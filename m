From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 11:27:50 +0200
Message-ID: <4A376596.7020602@trash.net>
References: <20090616061603.GA4494@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33949 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbZFPJ1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:27:50 -0400
In-Reply-To: <20090616061603.GA4494@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
>> --- a/drivers/net/wan/lapbether.c
>> +++ b/drivers/net/wan/lapbether.c
>> @@ -149,46 +149,42 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
>>   */
>>  static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
>>  {
>> -	int err = -ENODEV;
>> +	int err;
>>  
>>  	/*
>>  	 * Just to be *really* sure not to send anything if the interface
>>  	 * is down, the ethernet device may have gone.
>>  	 */
>>  	if (!netif_running(dev)) {
>> +		// XXX

Oops, wrong diff :) Will resend in a minute.

