From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] Interface groups, round two
Date: Thu, 18 Oct 2007 13:42:35 +0200
Message-ID: <471746AB.5070108@trash.net>
References: <11927025171404-git-send-email-panther@balabit.hu> <47173354.9060301@trash.net> <471744C3.3000801@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: panther@balabit.hu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <471744C3.3000801@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Patrick McHardy =EDrta:
>> Laszlo Attila Toth wrote:
>
>> The only reason why it can't be set to zero again seems to
>> be this part from the iproute patch:
>>
>> +            if (rtnl_ifgroup_a2n(&group, *argv) || group =3D=3D 0)
>>
>> Why don't you allow a value of zero?
>>
>=20
> It has historical reason. The original version which didn't use netli=
nk=20
> (at kernel 2.6.17) used zero to indicate that group was not set. You=20
> wrote previously that this part is useless for new kernels. I'll fix=20
> this (with type of "group" variable to unsigned int32 to be consisten=
t=20
> with the kernel part).

Support for ifgroups in the ioctl part is useless since that will
never be used with kernel supporting this feature. Setting it to
zero is not useless.



-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
