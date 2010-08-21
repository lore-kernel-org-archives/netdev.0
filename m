From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v8] PPTP: PPP over IPv4 (Point-to-Point Tunneling Protocol)
Date: Sat, 21 Aug 2010 20:42:09 +0800
Message-ID: <AANLkTimQwja4qF0X5gzG7u14+aXF_zVVZcwN5bHzku6V@mail.gmail.com>
References: <1282383066.2636.16.camel@edumazet-laptop> <E1OmmB6-0005es-00.xeb-mail-ru@f299.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46482 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab0HUMma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 08:42:30 -0400
Received: by wwi17 with SMTP id 17so5540687wwi.1
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 05:42:29 -0700 (PDT)
In-Reply-To: <E1OmmB6-0005es-00.xeb-mail-ru@f299.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 21, 2010 at 7:24 PM, Dmitry Kozlov <xeb@mail.ru> wrote:
>> > What is the next step ?
>>
>> David S. Miller review the thing, and if no problem remains, adds it to
>> its net-next-2.6 tree
>>
>> You can check netdev list of current patches right here :
>>
>> http://patchwork.ozlabs.org/project/netdev/list/
>>
>> Your patch is already there ;)
>
> Ah ok, thanks!
>
> I see some unexpected symbols in mail's subject, maybe i have to resend mail with subject cleaned ?

from Documentation/SubmittingPatches

 The "---" marker line serves the essential purpose of marking for patch
 handling tools where the changelog message ends.

I think the following lines from your patch are also useful, and you'd
better move them above the "---" marker.

 This patch introduces then pptp support to the linux kernel which
dramatically speeds up pptp vpn connections and decreases cpu usage in
comparison of existing user-space implementation (poptop/pptpclient).
There is accel-pptp project
(https://sourceforge.net/projects/accel-pptp/) to utilize this module,
it contains plugin for pppd to use pptp in client-mode and modified
pptpd (poptop) to build high-performance pptp NAS.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
