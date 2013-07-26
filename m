From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/tg3: Fix kernel crash
Date: Fri, 26 Jul 2013 14:28:36 -0700 (PDT)
Message-ID: <20130726.142836.1125568759731631815.davem@davemloft.net>
References: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
	<51EFC840.4010307@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shangw@linux.vnet.ibm.com, netdev@vger.kernel.org,
	mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932463Ab3GZV2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:28:37 -0400
In-Reply-To: <51EFC840.4010307@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Wed, 24 Jul 2013 05:27:44 -0700

> On 7/24/2013 2:25 AM, Gavin Shan wrote:
>> While EEH error happens, we might not have network device instance
>> (struct net_device) yet. So we can't access the instance safely and
>> check its link state, which causes kernel crash. The patch fixes it.
 ...
>> Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
...
> Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>

Applied.
