From: Akshat Kakkar <the_akshat@yahoo.co.in>
Subject: Re: Regarding vlan ingress filtering in linux
Date: Sun, 3 Feb 2013 17:39:54 +0800 (SGT)
Message-ID: <1359884394.48406.YahooMailNeo@web193304.mail.sg3.yahoo.com>
References: <1359810174.19988.YahooMailNeo@web193304.mail.sg3.yahoo.com> <1359813753.17144.YahooMailNeo@web193303.mail.sg3.yahoo.com> <CAKoUArmX=3w+qQzvhZugGAaZJxPJABTRKJFATEX6RSJ_WOo83w@mail.gmail.com>
Reply-To: Akshat Kakkar <the_akshat@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm13-vm1.bullet.mail.sg3.yahoo.com ([106.10.149.16]:44058 "EHLO
	nm13-vm1.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752914Ab3BCJqA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 04:46:00 -0500
In-Reply-To: <CAKoUArmX=3w+qQzvhZugGAaZJxPJABTRKJFATEX6RSJ_WOo83w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thanks for the reply.

I have following 4 different and independent requirements. How can I ac=
hieve this???

1.) There is no vlan on eth0 and I want any vlan tagged traffic on eth0=
 should not be processed.

2.) There is no vlan on eth0 and I want any vlan tagged traffic on eth0=
 should be processed as if it doesn't have any tag.

3.)
 There is vlan 10 on eth0 with inteface name as eth0.10. If there is an=
y
 untagged traffic on eth0, it should be processed as if it belongs to=20
vlan10.

4.) There is vlan 10 on eth0 with inteface name as eth0.10. If there is=
 any=20
untagged traffic on eth0, it should not be processed.


Any help will be highly appreciated?

Thanks and Regards,
-Akshat




----- Original Message -----
=46rom: Rami Rosen <roszenrami@gmail.com>
To: Akshat Kakkar <the_akshat@yahoo.co.in>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Sent: Saturday, 2 February 2013 11:23 PM
Subject: Re: Regarding vlan ingress filtering in linux

Hi,
If you are talking about disabling or setting rx vlan filter
offloading parameter, the latest ethtool (from git) has this:

=2E/ethtool -k p2p1
=2E...
rx-vlan-filter: off [fixed]
=2E...

But it seems to me that in order to set it (by "ethtool -K p2p1
rx-vlan-filter on") you need special support
from the device driver.

regards,
Rami Rosen
http://ramirose.wix.com/ramirosen




On Sat, Feb 2, 2013 at 4:02 PM, Akshat Kakkar <the_akshat@yahoo.co.in> =
wrote:
> Hi,
>
>
> Can you please help in providing info regarding vlan ingress filterin=
g in linux? I assume it should be configurable per port basis.
> I tried a lot on google, and all but was unable to find.
>
> Please help ...
>
> Thanks and regards
> - Akshat
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
