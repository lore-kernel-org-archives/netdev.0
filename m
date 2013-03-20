From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 22:16:37 +0300
Message-ID: <514A0B15.7000900@cogentembedded.com>
References: <201303200241.33137.sergei.shtylyov@cogentembedded.com> <20130320.122352.1542334118729356561.davem@davemloft.net> <514A0835.6070104@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:59943 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756144Ab3CTSPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:15:22 -0400
Received: by mail-la0-f49.google.com with SMTP id fs13so3538217lab.36
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:15:20 -0700 (PDT)
In-Reply-To: <514A0835.6070104@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2013 10:04 PM, Sergei Shtylyov wrote:

>
>>
>>> One must check the result of ioremap() -- in this case it prevents 
>>> potential
>>> kernel oops when initializing TSU registers further on...
>>>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Applied and queued up for -stable.
>
>    Thanks. However, do you really think it's needed in stable? It's 
> only error path, after all...

    I forgot to add "unlikely" to the "error path". I usually don't mark 
such patches for stable, when I'm not in a hurry. :-)

WBR, Sergei
