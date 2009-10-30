From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Fri, 30 Oct 2009 07:38:33 +0100
Message-ID: <4AEA89E9.30902@cosmosbay.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org> <20091029.232523.66969302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54373 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754845AbZJ3Gir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 02:38:47 -0400
In-Reply-To: <20091029.232523.66969302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 29 Oct 2009 17:16:54 -0700
>=20
>> I recently had it pointed out to me that the bonding driver does not
>> work in a network namespace.  So I have simplified the bonding drive=
r
>> a bit, added support for ip link add and ip link del, and finally ma=
de
>> the bonding driver work in multiple network namespaces.
>>
>> The most note worthy change in the patchset is the addition of suppo=
rt
>> in the networking core for registering a sysfs group for a device.
>>
>> Using this in the bonding driver simplifies the code and removes a
>> userspace race between actions triggered by the netlink event and th=
e
>> bonding sysfs attributes appearing.
>=20
> I have no objections to these patches, but I'd like the bonding
> folks to have a chance to look at it before I apply to net-next-2.6
>=20
> One question though, are you sure this clever extra slot scheme
> in patch #1 works for, f.e., a bond of wireless devices?  It seems
> like it would work out, but I wanted to ask to make sure you
> considered that case.
>=20

I have patches against bond driver for unregister_netdevice_queue() stu=
ff,
I'll wait for Eric work being committed first.

Thanks

