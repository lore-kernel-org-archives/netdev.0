From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Thu, 17 Sep 2015 16:02:41 -0700
Message-ID: <55FB4691.1060802@gmail.com>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk> <55F6AA25.2070603@list.ru> <20150914114209.GL21084@n2100.arm.linux.org.uk> <20150917.151247.2129216999071943354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, stsp@list.ru, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35179 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbbIQXCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:02:48 -0400
Received: by pacfv12 with SMTP id fv12so32000134pac.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 16:02:47 -0700 (PDT)
In-Reply-To: <20150917.151247.2129216999071943354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/09/15 15:12, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Mon, 14 Sep 2015 12:42:09 +0100
> 
>> Thanks, I think that will solve it.  I have to wonder why that patch
>> (f8af8e6eb9509 in mainline) didn't made it into v4.2 though, as it's
>> billed as a regression that occurred in the previous merge window, and
>> given that it was sent in July, and we're now in September.  As it
>> wasn't in v4.2, it looks like it should be a stable candidate.
> 
> The series had a whole bunch of non bug fixes in it and we were in
> the final phases of 4.2, in which case I defer to applying patches
> to net-next only unless I'm told otherwise.

To your defense, Staas and I kept arguing for a while, slowing the
entire process down until we agreed on a proper solution, the submission
was targeting your 'net' tree, but I did not realize until now that
these got applied to 'net-next'.

> 
> It's up the the patch/series author to let me know that an important
> regression fix is hidden in there, but they should have submitted
> it seperately from the rest in that kind of situation anyways.
> 
>> David, any objections to having the stable guys pick this regression
>> fix up, if not already done so?
> 
> More than this patch is needed, the one before it (3/4) instantiates
> the necessary property in the DT, for example.
> 
> I can queue up the whole series for -stable if you want.

I think this would be a good thing, mvneta-based platforms are fairly
popular.

Thank you!
-- 
Florian
