From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Wed, 21 Aug 2013 23:05:57 +0400
Message-ID: <52150F95.7060004@cogentembedded.com>
References: <521504E1.5060309@xdin.com> <1377111680.1936.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arvid Brodin <arvid.brodin@xdin.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:40816 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3HUTFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:05:52 -0400
Received: by mail-lb0-f178.google.com with SMTP id z5so934263lbh.37
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 12:05:50 -0700 (PDT)
In-Reply-To: <1377111680.1936.45.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/21/2013 11:01 PM, Joe Perches wrote:

>> High-availability Seamless Redundancy ("HSR") provides instant failover
>> redundancy for Ethernet networks. It requires a special network topology where
>> all nodes are connected in a ring (each node having two physical network
>> interfaces). It is suited for applications that demand high availability and
>> very short reaction time.

> Hi Arvid.

> just trivia:

>> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
> []
>> +static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
> []
>> +	if (likely(res1 == NET_XMIT_SUCCESS || res1 == NET_XMIT_CN ||
>> +		   res2 == NET_XMIT_SUCCESS || res2 == NET_XMIT_CN)) {

> This might be faster using | instead of ||

    Doesn't || use shortcut evaluation in C? I.e. if the 1st == evaluates to 
true, other comparisons are not even done.

WBR, Sergei
