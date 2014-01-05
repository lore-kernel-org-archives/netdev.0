From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/6] phylib: cleanups
Date: Sun, 05 Jan 2014 17:40:08 +0400
Message-ID: <52C960B8.1020607@cogentembedded.com>
References: <201401040413.06853.sergei.shtylyov@cogentembedded.com> <20140104155338.GG4925@netboy> <52C8417D.6020502@cogentembedded.com> <52C858C7.1010300@cogentembedded.com> <20140105083109.GB4933@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36093 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbaAENkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 08:40:10 -0500
Received: by mail-lb0-f174.google.com with SMTP id y6so9156659lbh.19
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 05:40:09 -0800 (PST)
In-Reply-To: <20140105083109.GB4933@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-01-2014 12:31, Richard Cochran wrote:

>>>     Because get_maintainer.pl doesn't suggest it and because Andy Fleming
>>> seems no longer interested in maintaining his code written back in 2004.

> It never hurts to ask.

    I would have probably asked if there were not so many obstacles to doing that.

> Your patches are saying, "Andy, your code has poor style."

    It's coming back from 2004, so maybe the style wasn't considered bad at 
that time...

> I don't
> agree, especially about #3.

    It's your right. However, v2 of the patchset has been applied already.

> Also, maybe the deleted callback will
> useful one day.

    We kept it for almost 10 years and it never got useful. As I understood 
DaveM's policy it is "we don't keep unused stuff".

> After all, there are not that many phylib drivers.

    Really? I find the number to be intimidating enough to not do the cleanups 
on them also in this same patchset. Anyway, the callback was intended for the 
Ethernet drivers.

> Perhaps future MAC drivers will need this.

    We can always add it back in that case. However, phy_start_machine() which 
is the only way to set the callback was not even exported, so not generally 
usable for the MAC drivers. I guess this facility wasn't well thought out from 
the start.

>>     Besides, I don't have his current email address (the source code
>> doesn't provide any).

> Here, let me find that for you.

    Thanks I found those eventually. However, my LinkedIn account told me that 
Andy left Freescale about that time (it also gave up his private email though).

> Thanks,
> Richard

WBR, Sergei
