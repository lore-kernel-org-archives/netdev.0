From: Silviu Popescu <silviupopescu1990@gmail.com>
Subject: Re: [PATCH] ethernet: nxp: use resource_size()
Date: Wed, 13 Mar 2013 00:35:31 +0200
Message-ID: <CAPWTe+JhUJBsCLekeADe4FesC95nYh16XHrj0cOk97JfnjF49g@mail.gmail.com>
References: <1363113035-11269-1-git-send-email-silviupopescu1990@gmail.com>
	<1363115431.2125.13.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, stigge@antcom.de,
	edumazet@google.com, gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:55186 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933712Ab3CLWfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 18:35:32 -0400
In-Reply-To: <1363115431.2125.13.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 9:10 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2013-03-12 at 20:30 +0200, Silviu-Mihai Popescu wrote:
>> Use resource_size() instead of explicit calculation. This was found via
>> make coccicheck.
> []
>> diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
> []
>> @@ -1421,7 +1421,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
>>       netdev_dbg(ndev, "IO address start     :0x%08x\n",
>>                       res->start);
>>       netdev_dbg(ndev, "IO address size      :%d\n",
>> -                     res->end - res->start + 1);
>> +                     resource_size(res));
>
> This might be better as
>
>         netdev_dbg(ndev, "IO resource    :%pR\n", res);
>
>

Thanks for the review. I've refreshed the patch and sent it again.

-- 
Silviu Popescu
