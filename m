From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH 02/14 v2] mac802154: allocation of ieee802154 device
Date: Wed, 28 Dec 2011 10:19:23 +0300
Message-ID: <CAJmB2rAyyPmYTmtTvFK3UuFn9t+361raA5R=92XPNHrH7dfgfw@mail.gmail.com>
References: <CAJmB2rBMVvw_TV-mT2-jT7=H0adfMWaYFC0Q908pc_ND+PLD_g@mail.gmail.com>
	<1324919047-14851-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<20111226.150924.734645949941473044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:55114 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751258Ab1L1HTZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 02:19:25 -0500
Received: by lahd3 with SMTP id d3so2229600lah.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 23:19:23 -0800 (PST)
In-Reply-To: <20111226.150924.734645949941473044.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

2011/12/26 David Miller <davem@davemloft.net>:
> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> Date: Mon, 26 Dec 2011 20:04:07 +0300
>
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* SoftMAC device is registered and running. One can add
>> + =A0 =A0 =A0* subinterfaces.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned running:1;
>
> I told you to change this to a 'bool' in my previous review of your c=
hanges.
>
> I'm pretty much going to stop reviewing right here, because I don't
> want to waste my time only to find out that you've ignored other
> review feedback I've already given to you.
>

Regarding your comments to my previous post, none of them was omitted. =
I
reworked code according to them and added extended comments in a patch
explaining why I can't follow your hint. The issue with 'bool' you mark=
ed
was in another patch (#14) which I already fixed.

Of course I'm newcomer here, so there are lots refinements I don't
know about and may understand you incorrectly.

Best regards,
Alex

> I think it's also instructive to note that your difficulty just
> posting this patch series, with all your "email client problems", is
> indicative of the much larger issue which is that you're rushing
> things and you need to take more time working on and posting these
> patches.
