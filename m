From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: Regarding vlan ingress filtering in linux
Date: Sat, 2 Feb 2013 19:53:06 +0200
Message-ID: <CAKoUArmX=3w+qQzvhZugGAaZJxPJABTRKJFATEX6RSJ_WOo83w@mail.gmail.com>
References: <1359810174.19988.YahooMailNeo@web193304.mail.sg3.yahoo.com>
	<1359813753.17144.YahooMailNeo@web193303.mail.sg3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Akshat Kakkar <the_akshat@yahoo.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:50018 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757137Ab3BBRxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 12:53:07 -0500
Received: by mail-qa0-f54.google.com with SMTP id hg5so772955qab.20
        for <netdev@vger.kernel.org>; Sat, 02 Feb 2013 09:53:06 -0800 (PST)
In-Reply-To: <1359813753.17144.YahooMailNeo@web193303.mail.sg3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
If you are talking about disabling or setting rx vlan filter
offloading parameter, the latest ethtool (from git) has this:

./ethtool -k p2p1
....
rx-vlan-filter: off [fixed]
....

But it seems to me that in order to set it (by "ethtool -K p2p1
rx-vlan-filter on") you need special support
from the device driver.

regards,
Rami Rosen
http://ramirose.wix.com/ramirosen




On Sat, Feb 2, 2013 at 4:02 PM, Akshat Kakkar <the_akshat@yahoo.co.in> wrote:
> Hi,
>
>
> Can you please help in providing info regarding vlan ingress filtering in linux? I assume it should be configurable per port basis.
> I tried a lot on google, and all but was unable to find.
>
> Please help ...
>
> Thanks and regards
> - Akshat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
