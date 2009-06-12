From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC net 00/03]: dev_queue_xmit error propagation
Date: Fri, 12 Jun 2009 02:10:50 +0200
Message-ID: <4A319D0A.1060100@trash.net>
References: <20090609161658.6730.59754.sendpatchset@x2.localnet>	<20090611.031852.90563118.davem@davemloft.net>	<4A3131D6.40807@trash.net> <20090611.170512.97427064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64180 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760973AbZFLAKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:10:51 -0400
In-Reply-To: <20090611.170512.97427064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 11 Jun 2009 18:33:26 +0200
>
>   
>> I still need to verify that no drivers are using the raw values for
>> the NETDEV_TX codes since NETDEV_TX_LOCKED is using a different
>> value with my patch.
>>     
>
> Yeah, auditing 500 ->hard_start_xmit implementations is fun.
>   

Indeed. Found about 30 which are already returning errno codes :)

