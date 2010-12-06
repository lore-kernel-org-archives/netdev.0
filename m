From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: add the correct LRO status at dev->features
Date: Mon, 06 Dec 2010 14:57:26 -0200
Message-ID: <4CFD15F6.7040609@linux.vnet.ibm.com>
References: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com> <20101206084824.637d6b29@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:56764 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955Ab0LFQ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 11:57:38 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id oB6HIoMU031109
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 15:18:50 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB6H4erI3141834
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 15:04:44 -0200
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB6GvVT3028329
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 14:57:31 -0200
In-Reply-To: <20101206084824.637d6b29@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2010 02:48 PM, Stephen Hemminger wrote:
> On Mon,  6 Dec 2010 14:39:42 -0200
> leitao@linux.vnet.ibm.com wrote:
>
>> Currently ehea is not setting NETIF_F_LRO, and it is not providing
>> a callback for get_flags on ethtool. This patch fixes it.
>>
>> Signed-off-by: Breno Leitao<leitao@linux.vnet.ibm.com>
>
> More importantly, ehea does not support set_flags to disable LRO.
Correct, currently LRO is a module parameter. I have an item in my TODO 
list to implement set_flags, and thus, the LRO scheme.

So, if you prefer I can send this patch with the future set_flags ones. 
But, for now, this patch allows the user to check when LRO is enabled. 
As it is today, it shows that LRO is disabled all the time.

Anyway, you choose what is the best option.

Thanks,
Breno
