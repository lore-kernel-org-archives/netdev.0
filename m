From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: Fwd: DA850-evm MAC Address is random
Date: Tue, 5 Sep 2017 10:12:11 +0530
Message-ID: <1865772b-482e-042e-7c66-d33290f0d8fb@ti.com>
References: <CAHCN7xKwFd7dHF0ySEd1hOSr0sZEgh9fuwy=RkUTHvEh59hojQ@mail.gmail.com>
 <b7aab9fc-17ba-077b-3ff3-28087e0b25bc@ti.com>
 <CAHCN7xLHEjda9DcVw5iHA9RaJ7UnyMVxf7e4e8NTEj9Op1JaBw@mail.gmail.com>
 <20170828211217.GO6008@atomide.com>
 <94c4cbb0-1df3-2f2f-69f3-f9a788e610fa@ti.com>
 <CAHCN7x+-wymsqw96mt7Du=Huxh5rq=Rj9GidWPLXptJSW7taEA@mail.gmail.com>
 <f0f5e11f-cd7a-cb86-58b5-8ce44cdbc032@ti.com>
 <CAHCN7xK2=PN5MOr48HOkZnwKwkM4ypcvQct+Ko+ChNFG3Pv62w@mail.gmail.com>
 <955b0b1b-9bb7-ad25-4d6c-676be1efb943@ti.com>
 <CAHCN7x+paAdW7cXrALhtLZZiJbkE6v_8_qRXBec7hxLJPvSMbw@mail.gmail.com>
 <CAHCN7xKfZeyTHZShWGYYen50NSzTErh8X8np3WJfrYTBrO_RPw@mail.gmail.com>
 <ffec81da-78b6-7f1a-e477-ab0a9d2e4f37@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Tony Lindgren <tony@atomide.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: Adam Ford <aford173@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:46749 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdIEEmR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 00:42:17 -0400
In-Reply-To: <ffec81da-78b6-7f1a-e477-ab0a9d2e4f37@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Adam,

On Wednesday 30 August 2017 11:08 AM, Sekhar Nori wrote:
>> I wonder if U-Boot isn't pushing something to Linux because it doesn't
>> appear to be running some of the da850 specific code even when I run
>> linux-next.  Can you tell me what verision of U-Boot you're using?
>> Other than using davinci_all_defconfig, did you change the
>> configuration at all?

> I am using U-Boot 2017.01. Yes, the kernel was built using
> davinci_all_defconfig and no other config change. Before booting kernel,
> can you confirm that ethaddr is set in U-Boot environment? This is what
> fdt_fixup_ethernet() reads to fixup the FDT before boot.
> 
> Here is my complete boot log with environment variable dump.
> 
> http://pastebin.ubuntu.com/25430265/

Were you able to get rid of the random mac address problem?

Thanks,
Sekhar
