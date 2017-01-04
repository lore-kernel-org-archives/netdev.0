From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] sh_eth: factor out sh_eth_emac_interrupt()
Date: Wed, 4 Jan 2017 15:20:51 +0300
Message-ID: <130641f5-8e91-d8e0-b97e-587a99135942@cogentembedded.com>
References: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
 <2316251.zKWDf5AMHG@wasted.cogentembedded.com>
 <cab4c624-2225-beed-25f5-7bcf25b16e9b@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34265 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932322AbdADMU4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:20:56 -0500
Received: by mail-lf0-f45.google.com with SMTP id d16so11983965lfb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:20:55 -0800 (PST)
In-Reply-To: <cab4c624-2225-beed-25f5-7bcf25b16e9b@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 03:13 PM, Sergei Shtylyov wrote:

>> The E-MAC interrupt (EESR.ECI) is not always caused  by an error condition,
>> so  it really shouldn't be handled by sh_eth_error(). Factor out the E-MAC
>> interrupt handler, sh_eth_emac_interrupt(),  removing the ECI bit from the
>> EESR's values throughout the driver...
>>
>> Update Cogent Embedded's copyright and clean up the whitespace in Renesas'
>> copyright, while at it...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
>    Scrap it, I've just realized I never enable EESR.ECI...

    Heh, hat was false alarm -- I didn't change the .eesipr_value in the 
patch, so everything's OK, you can merge this series.
    I'll look into avoiding bare numbers in the .eesipr_value initializers.

MBR, Sergei
