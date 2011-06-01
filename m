From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6] bonding: allow resetting slave failure counters
Date: Wed, 01 Jun 2011 21:34:45 +0200
Message-ID: <4DE69455.3080203@gmail.com>
References: <4DE63E85.7020508@redhat.com>	<20110601135321.GA2909@psychotron.brq.redhat.com>	<16056.1306944819@death> <20110601.120300.130602301077156524.davem@davemloft.net> <4DE68ECB.70802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, fubar@us.ibm.com,
	jpirko@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38856 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759171Ab1FATes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 15:34:48 -0400
Received: by wya21 with SMTP id 21so102007wya.19
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2011 12:34:47 -0700 (PDT)
In-Reply-To: <4DE68ECB.70802@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/06/2011 21:11, Flavio Leitner a =E9crit :
> On 06/01/2011 04:03 PM, David Miller wrote:
>> From: Jay Vosburgh<fubar@us.ibm.com>
>> Date: Wed, 01 Jun 2011 09:13:39 -0700
>>
>>> 	The "this dingus was added in version X.Y.Z" is there because
>>> users sometimes read the most recent version of the documentation (=
that
>>> they get from the internet) and then would become confused when the=
ir
>>> older distro driver lacked some option described in the documentati=
on.
>>
>> I disagree with this whole concept, because distros backport feature=
s
>> like this into their kernel and therefore the feature is showing up =
in
>> version X.Y.$(Z-20).
>
> It doesn't matter the version if the user can find the feature, so
> distros backporting features works and that info is not useful at all=
=2E
> However, when the user doesn't find the feature and search the intern=
et,
> then that info is helpful.

There are *many* new features that get included into the kernel without=
 documenting the exact first=20
version that provide them. Why should we need this for bonding? Also, b=
ecause we lack a table that=20
gives the kernel version matching a bonding version, the user is not re=
ally helped by "you need=20
version X.Y.Z of bonding to have this feature".

So, I'm not sure it helps...

	Nicolas.
