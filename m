From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: disable at run-time the EEE if
 not supported
Date: Tue, 20 Aug 2013 17:04:16 -0700 (PDT)
Message-ID: <20130820.170416.2028716553359945223.davem@davemloft.net>
References: <1376894288-31279-1-git-send-email-peppe.cavallaro@st.com>
	<52126788.4060607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab3HUAER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 20:04:17 -0400
In-Reply-To: <52126788.4060607@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 19 Aug 2013 22:44:24 +0400

>> @@ -2166,7 +2181,6 @@ static int stmmac_poll(struct napi_struct *napi,
>> int budget)
>>   static void stmmac_tx_timeout(struct net_device *dev)
>>   {
>>   	struct stmmac_priv *priv = netdev_priv(dev);
>> -
>>   	/* Clear Tx resources and restart transmitting again */
> 
>    Why? This seems unneeded change.

Agreed, not only was this code properly styled already, changing it
is totally unrelated to what this patch is supposed to be doing.
