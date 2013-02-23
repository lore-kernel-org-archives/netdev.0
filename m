From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Sat, 23 Feb 2013 08:46:58 +0800
Message-ID: <CAHrpEqRhCyM8z8th0ktYErUYPtLXVayEJm0BZSb6WWm=7dgN5w@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<loom.20130204T174808-896@post.gmane.org>
	<CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com>
	<loom.20130205T111507-687@post.gmane.org>
	<CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
	<51125F28.4000409@intel.com>
	<CAHrpEqR9u5t8fZOYRq4k_vTsEORVsNwa2C_rLaxesmusY5e9-Q@mail.gmail.com>
	<loom.20130222T132206-265@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32805 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711Ab3BWArA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 19:47:00 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm14so1384910wib.16
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 16:46:59 -0800 (PST)
In-Reply-To: <loom.20130222T132206-265@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/22 Jim Baxter <jim_baxter@mentor.com>:
>> > On 2/6/2013 1:50 AM, Frank Li wrote:
>> >>
>> >>
>> >> It is not easy to fix. Need put tx to NAPI poll function.
>> >> I will work on that after China New year holiday
>
>
>
> Hi Frank,
>
> Have you had time to have a look at this issues again?

Does it happen when run ptp4?
I am working on put xmit to NAPI and remove lock.


>
> Jim
>
>
>
>
>
>
>
>
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
