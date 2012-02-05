From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] net: fec: Remove macaddr option
Date: Sun, 5 Feb 2012 17:18:36 -0500
Message-ID: <CAP=VYLrjWQX8ixV_fYBrpsMkYt+tug7OpWWgEq+R-qeu7rm=Qg@mail.gmail.com>
References: <1328289904-22401-1-git-send-email-fabio.estevam@freescale.com>
	<20120204.162936.1988486080455883986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.estevam@freescale.com, netdev@vger.kernel.org,
	kernel@pengutronix.de, shawn.guo@freescale.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:34714 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab2BEWSg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 17:18:36 -0500
Received: by ggnh1 with SMTP id h1so2526190ggn.19
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2012 14:18:36 -0800 (PST)
In-Reply-To: <20120204.162936.1988486080455883986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 4, 2012 at 4:29 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> Date: Fri, 3 Feb 2012 15:25:04 -0200
>
>> "macaddr" option allows users to pass the MAC address via kernel com=
mand line.
>>
>> Feedbacks from Alan Cox and David Miller (http://www.spinics.net/lis=
ts/linux-usb/msg57821.html )
>> mention that this is not a good idea, so remove it.
>>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>
> Whilst we can prevent new additions of such module options, you can't
> just go and remove them from existing drivers without potentially
> breaking things for people.
>
> In this FEC case, the option was added more than a year ago.
>
> I'm not applying this patch.

How about a patch to feature-removal-schedule.txt instead?  I don't
know Fabio from a bar of soap, but to his credit, it seems he has been
paying attention to recent netdev threads, and is trying to improve thi=
ngs
based on what he has seen recently -- even if he's not aware of the
general linux intent to not break things that worked in the past.

Most of these "create MAC at random" threads are supported by people
pointing at existing instances, and making the common mistake of thinki=
ng
that crimes of the past justify similar crimes in the present.  (Hint -=
 no they
do not.)   So to that end, removing another instance is probably good -=
- if it
is communicated in advance...  even if delayed via feature-removal.

To my knowledge, the platforms using FEC are pretty limited, and if the
folks at Freescale want to remove the MAC setting option, then great.

Paul.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
