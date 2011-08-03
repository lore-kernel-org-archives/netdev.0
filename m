From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: bonding and ifenslave version.
Date: Wed, 03 Aug 2011 21:38:15 +0200
Message-ID: <4E39A3A7.1080905@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>	<4E38EE23.8030703@gmail.com> <CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64706 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1HCTic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 15:38:32 -0400
Received: by wyf22 with SMTP id 22so68753wyf.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 12:38:31 -0700 (PDT)
In-Reply-To: <CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/08/2011 21:03, Andy Gospodarek a =E9crit :

>> I thought introducing a new option should cause the driver version t=
o
>> change. Am I right?
>
> When a significant change happens, we try to change the version
> number.  The version number probably should have been changed when
> those were added.  Inspecting the module options or sysfs parameters
> indicate whether or not these patches were added, so it is less of a
> priority than when some internal infrastructure (like moving to use
> rx_handler) changes.
>
> I consider it more critical to change the bonding module version when
> something changes that cannot be detected by inspecting the module or
> sysfs parameters.  This is more helpful to users reporting problems.
>

Ok, 'sounds perfectly sensible to me, thanks.

>> On a different but related topic, the version in
>> Documentation/networking/ifenslave.c (1.1.0) didn't change since the=
 git
>> origin and probably since 2003.
>>
>> Arguably, none of the commit regarding this file introduced a signif=
icant
>> change (with the possible exception of commit
>> e6d184e33109010412ad1d59719af74755a935f4, [NET]: Fix ifenslave to no=
t fail
>> on lack of IP information). But if we never change a 3-level version=
 number,
>> whatever the level of change, this version number might be useless. =
Any
>> comment?
>>
>>         Nicolas.
>>
>
> Distributions benefit from version numbers on userspace utils.  It
> would probably be better to keep ifenslave's version number as it is
> to help those maintaining those distro packages.

As one of the maintainers for the ifenslave package on Debian, I perfec=
tly understand the need for=20
an upstream version, but as such, I expected the upstream version numbe=
r to change when the file=20
change... Version numbers in Debian use upstream version numbers when a=
vailable and add a subversion=20
number for Debian specific changes. I would expect to change the versio=
n number and not only the=20
Debian subversion when the only change is a new upstream version.

Anyway, it is not that important and I can leave with 1.1.0 for long :-=
D

Thanks again.

	Nicolas.



