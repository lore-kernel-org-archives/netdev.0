From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 3/3] sh_eth: use managed device API
Date: Fri, 22 Mar 2013 01:43:54 +0300
Message-ID: <514B8D2A.2090408@cogentembedded.com>
References: <201303220135.51520.sergei.shtylyov@cogentembedded.com> <20130321.173523.2134000966916487176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:33139 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3CUVmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:42:37 -0400
Received: by mail-la0-f45.google.com with SMTP id er20so6159049lab.32
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 14:42:34 -0700 (PDT)
In-Reply-To: <20130321.173523.2134000966916487176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/22/2013 12:35 AM, David Miller wrote:

>
>> Switch the driver to the managed device API by replacing ioremap() calls with
>> devm_ioremap_resource() (which will also result in calling request_mem_region()
>> which the driver forgot to do until now) and k[mz]alloc() with devm_kzalloc() --
>> this permits to simplify driver's probe()/remove() method cleanup. We can now
>> remove the ioremap() error messages since the error messages are printed by
>>   devm_ioremap_resource() itself. We can also remove the 'bitbang' field from
>> 'struct sh_eth_private' as we don't need it anymore in order to free the memory
>> behind it...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>> Changes since initial posting:
>> - removed unused 'mdp' variable in sh_eth_drv_remove().
>>
>> Sorry, I seem to have missed the unused variable warning... :-/
> I already applied your original patch.

    Thanks, you're really quick. Maybe too quick. :-)

> Please read your email before posting new versions of patches.

    I'm monitoring my mail constantly but was just somewhat carried away
by testing a new patch when I suddenly saw the warning and went on to
fix it immediately. Unfortunately, it was already too late. :-(

> You have to send me a relative fix since your patches are applied
> already.

    Will send in a jiffy...

WBR, Sergei
