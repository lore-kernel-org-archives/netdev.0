From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] sh_eth: fix bitbang memory leak
Date: Wed, 20 Mar 2013 22:06:16 +0300
Message-ID: <514A08A8.9080704@cogentembedded.com>
References: <201303200240.23975.sergei.shtylyov@cogentembedded.com> <20130320.122346.949755604432580585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:38809 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159Ab3CTSFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:05:02 -0400
Received: by mail-la0-f49.google.com with SMTP id fs13so3517619lab.36
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:04:59 -0700 (PDT)
In-Reply-To: <20130320.122346.949755604432580585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/20/2013 07:23 PM, David Miller wrote:

>
>> sh_mdio_init() allocates pointer to 'struct bb_info' but only stores it locally,
>> so that sh_mdio_release() can't free it on driver unload.  Add the pointer to
>> 'struct bb_info' to 'struct sh_eth_private', so that sh_mdio_init() can save
>> 'bitbang' variable for sh_mdio_release() to be able to free it later...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Applied and queued up for -stable.

    Thank you for the quick reaction! :-)

WBR, Sergei
