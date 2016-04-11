From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: re-enable-E-MAC interrupts in
 sh_eth_set_ringparam()
Date: Mon, 11 Apr 2016 20:10:50 +0300
Message-ID: <570BDA9A.4030107@cogentembedded.com>
References: <2542968.R3YjY2kHV4@wasted.cogentembedded.com>
 <20160409.212725.649496142802966013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:32967 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbcDKRKz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 13:10:55 -0400
Received: by mail-lf0-f42.google.com with SMTP id e190so164710422lfe.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 10:10:54 -0700 (PDT)
In-Reply-To: <20160409.212725.649496142802966013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/10/2016 04:27 AM, David Miller wrote:

>> The E-MAC interrupts are left disabled when the ring parameters are changed
>> via 'ethtool'. In order to fix this, it's enough to call sh_eth_dev_init()
>> with 'true' instead of 'false' for the second argument (which conveniently
>> allows us to remove the following code re-enabling E-DMAC interrupts and
>> reception).
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> Applied, thanks.

    Thanks!
    Unfortunately, this patch isn't fit for the stable kernels because there's 
a prerequisite cleanup (most recent patch merged to this driver). I clearly 
hadn't thought this out well -- should have enabled the E-MAC interrupts 
outside sh_eth_dev_init() and then removed the duplicate code like I did here.

MBR, Sergei
