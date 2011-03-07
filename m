From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 4/8] bonding: wrap slave state work
Date: Mon, 07 Mar 2011 20:55:12 +0100
Message-ID: <4D753820.2070608@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-5-git-send-email-jpirko@redhat.com> <4D7254E9.6090605@gmail.com> <20110307095839.GC2832@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45466 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab1CGTzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 14:55:14 -0500
Received: by wyg36 with SMTP id 36so4517762wyg.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 11:55:13 -0800 (PST)
In-Reply-To: <20110307095839.GC2832@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 10:58, Jiri Pirko a =E9crit :
>>>
>>> +static inline void bond_set_active_slave(struct slave *slave)
>>> +{
>>> +	slave->backup =3D 0;
>>
>> In the comment above, you said that the possible value for backup
>> corresponds with BOND_STATE_ACTIVE and BOND_STATE_BACKUP.
>>
>> So, should be:
>>
>> slave->backup =3D BOND_STATE_ACTIVE;
>>
>>> +}
>>> +
>>> +static inline void bond_set_backup_slave(struct slave *slave)
>>> +{
>>> +	slave->backup =3D 1;
>>
>> slave->backup =3D BOND_STATE_BACKUP;
>>
>
> Well, I think it's weird and misleading to assign some define to :1
> bitfield. Should be 0 or 1, nothing else.

Agreed, but the comment appears missleading... May be you should fix th=
e comment, not the code.

	Nicolas.

