From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding and ifenslave version.
Date: Thu, 04 Aug 2011 23:20:16 +0200
Message-ID: <4E3B0D10.4020907@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>	<4E38EE23.8030703@gmail.com>	<CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>	<4E39A3A7.1080905@gmail.com>	<1718.1312402077@death>	<4E39B1AB.7050502@gmail.com>	<20110803143338.03988aab@nehalam.ftrdhcpuser.net>	<4E3A2EBA.4040003@gmail.com> <20110804095704.46c453d0@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61210 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab1HDVUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 17:20:20 -0400
Received: by wwe5 with SMTP id 5so2302180wwe.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 14:20:19 -0700 (PDT)
In-Reply-To: <20110804095704.46c453d0@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/08/2011 18:57, Stephen Hemminger a =E9crit :
> On Thu, 04 Aug 2011 07:31:38 +0200
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
<snip>
>> Or do you mean, to replace ifenslave (.c) by a shell script that use=
 netlink internally? Are all the
>> bonding options available through netlink? I remember many conversat=
ion about using netlink for
>> bonding setup, but don't remember seeing that in the actual code.
>
> The sysfs interface is the least desirable.
> The ifenslave script would just call 'ip link'

=46or as far as I know, ip link is able to enslave and to detach a slav=
e, but not to change the active=20
slave. So I think you cannot mimic the -c|--change-active option of ife=
nslave just using iproute. Do=20
I miss something?

That being said, I'm not sure this particular option is the most used o=
ne, but...

	Nicolas.

