From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: bonding and ifenslave version.
Date: Wed, 3 Aug 2011 15:03:17 -0400
Message-ID: <CAHashqCrRq3z_bwddy3Y3+t+hmA4oN3hndmsTKUDNc73U=c3Gg@mail.gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
	<4E38EE23.8030703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51538 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab1HCTDT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 15:03:19 -0400
Received: by eyx24 with SMTP id 24so1130868eyx.19
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2011 12:03:17 -0700 (PDT)
In-Reply-To: <4E38EE23.8030703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2011 at 2:43 AM, Nicolas de Peslo=FCan
<nicolas.2p.debian@gmail.com> wrote:
> Le 02/08/2011 22:06, Nicolas de Peslo=FCan a =E9crit :
>>
>> Commit 655f8919d549ad1872e24d826b6ce42530516d2e
>> =A0 =A0 bonding: add min links parameter to 802.3ad
>>
>> and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
>> =A0 =A0 bonding: add all_slaves_active parameter
>>
>> introduced new options to bonding, but didn't provide the documentat=
ion
>> for those options.
>>
>> Signed-off-by: Nicolas de Peslo=FCan<nicolas.2p.debian@free.fr>
>> ---
>
> Jay, Andy,
>
> While working at this patch, I noticed that the bonding driver versio=
n
> wasn't bumped up at the time those options were introduced.
>
> I thought introducing a new option should cause the driver version to
> change. Am I right?

When a significant change happens, we try to change the version
number.  The version number probably should have been changed when
those were added.  Inspecting the module options or sysfs parameters
indicate whether or not these patches were added, so it is less of a
priority than when some internal infrastructure (like moving to use
rx_handler) changes.

I consider it more critical to change the bonding module version when
something changes that cannot be detected by inspecting the module or
sysfs parameters.  This is more helpful to users reporting problems.

> On a different but related topic, the version in
> Documentation/networking/ifenslave.c (1.1.0) didn't change since the =
git
> origin and probably since 2003.
>
> Arguably, none of the commit regarding this file introduced a signifi=
cant
> change (with the possible exception of commit
> e6d184e33109010412ad1d59719af74755a935f4, [NET]: Fix ifenslave to not=
 fail
> on lack of IP information). But if we never change a 3-level version =
number,
> whatever the level of change, this version number might be useless. A=
ny
> comment?
>
> =A0 =A0 =A0 =A0Nicolas.
>

Distributions benefit from version numbers on userspace utils.  It
would probably be better to keep ifenslave's version number as it is
to help those maintaining those distro packages.
