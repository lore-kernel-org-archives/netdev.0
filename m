From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding and ifenslave version.
Date: Thu, 04 Aug 2011 07:31:38 +0200
Message-ID: <4E3A2EBA.4040003@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>	<4E38EE23.8030703@gmail.com>	<CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>	<4E39A3A7.1080905@gmail.com>	<1718.1312402077@death>	<4E39B1AB.7050502@gmail.com> <20110803143338.03988aab@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41629 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab1HDFbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2011 01:31:41 -0400
Received: by wwe5 with SMTP id 5so1528471wwe.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 22:31:40 -0700 (PDT)
In-Reply-To: <20110803143338.03988aab@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2011 23:33, Stephen Hemminger a =E9crit :
> On Wed, 03 Aug 2011 22:38:03 +0200
> Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>  wrote:
<snip>
>> At least, we can:
>> - update the bonding documentation to clarify that ifenslave is depr=
ecated (and move most ifenslave
>> related stuffs at the end of the documentation);
>> - possibly issue a warning when the API is used, suggesting to use s=
ysfs instead.
>>
>> I can take care of the documentation update if appropriate.
>>
>> 	Nicolas.
>
> Or I could just put a shell script that does the same thing in iprout=
e.

You mean, to replace ifenslave (from ifenslave.c) by a shell script by =
the same name that gives=20
users the same command-line interface but use sysfs instead of the ioct=
l API internally?

I had this in mind two years ago, in a private conversation while chang=
ing the ifenslave package on=20
Debian.

But chance exist that those who expect ifenslave to work would like to =
disable sysfs support if not=20
used. I assume that totally disabling sysfs at compile time would reduc=
e the size of the kernel far=20
more that disabling the ioctl API. So, for those doing embedded things,=
 this may makes sens to have=20
an ifenslave version that doesn't rely on sysfs.

Or do you mean, to replace ifenslave (.c) by a shell script that use ne=
tlink internally? Are all the=20
bonding options available through netlink? I remember many conversation=
 about using netlink for=20
bonding setup, but don't remember seeing that in the actual code.

	Nicolas.
