From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 0/2] Interface groups, round two
Date: Thu, 18 Oct 2007 13:34:27 +0200
Message-ID: <471744C3.3000801@balabit.hu>
References: <11927025171404-git-send-email-panther@balabit.hu> <47173354.9060301@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:45023 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815AbXJRLec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 07:34:32 -0400
In-Reply-To: <47173354.9060301@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> Hello,
>>
>> Here is the new version of ifgroup patches.
>>
>> The interface group value is u_int32_t in net_device which should be=
=20
>> enough.
>> Previously it was an int.
>>
>> Usage:
>>    ip link set eth0 group 4
>> but currently it cannot be unset, only changed to another value.
>=20
>=20
> The only reason why it can't be set to zero again seems to
> be this part from the iproute patch:
>=20
> +            if (rtnl_ifgroup_a2n(&group, *argv) || group =3D=3D 0)
>=20
> Why don't you allow a value of zero?
>=20

It has historical reason. The original version which didn't use netlink=
=20
(at kernel 2.6.17) used zero to indicate that group was not set. You=20
wrote previously that this part is useless for new kernels. I'll fix=20
this (with type of "group" variable to unsigned int32 to be consistent=20
with the kernel part).

--=20
Attila
