From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 2/2] net: phy: at803x: add suspend/resume callbacks
Date: Fri, 27 Sep 2013 20:49:00 +0200
Message-ID: <5245D31C.4080104@gmail.com>
References: <1379775182-1271-1-git-send-email-zonque@gmail.com> <1379775182-1271-2-git-send-email-zonque@gmail.com> <523E877F.4050906@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ujhelyi.m@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:39235 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab3I0StE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 14:49:04 -0400
Received: by mail-bk0-f51.google.com with SMTP id mx10so1141131bkb.10
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 11:49:01 -0700 (PDT)
In-Reply-To: <523E877F.4050906@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.09.2013 08:00, Mugunthan V N wrote:
> On Saturday 21 September 2013 08:23 PM, Daniel Mack wrote:
>> When WOL is enabled, the chip can't be put into power-down (BMCR_PDOWN)
>> mode, as that will also switch off the MAC, which consequently leads to
>> a link loss.
>>
>> Use BMCR_ISOLATE in that case, which will at least save us some
>> milliamperes in comparison to normal operation mode.
>>
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Looks good to me
> 
> Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Thanks :)

David, can you take these two patches with Mugunthan's Acked-by: or do
you want me to resend them?


Best regards,
Daniel
