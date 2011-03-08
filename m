From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 4/8] bonding: wrap slave state work
Date: Tue, 08 Mar 2011 22:23:15 +0100
Message-ID: <4D769E43.7040708@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-5-git-send-email-jpirko@redhat.com> <4D7254E9.6090605@gmail.com> <20110307095839.GC2832@psychotron.brq.redhat.com> <4D753820.2070608@gmail.com> <20110308071805.GB2826@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:32982 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab1CHVXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 16:23:20 -0500
Received: by wwa36 with SMTP id 36so1653313wwa.1
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 13:23:19 -0800 (PST)
In-Reply-To: <20110308071805.GB2826@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/03/2011 08:18, Jiri Pirko a =E9crit :
> Mon, Mar 07, 2011 at 08:55:12PM CET, nicolas.2p.debian@gmail.com wrot=
e:
>> Le 07/03/2011 10:58, Jiri Pirko a =E9crit :
>>>>>
>>>>> +static inline void bond_set_active_slave(struct slave *slave)
>>>>> +{
>>>>> +	slave->backup =3D 0;
>>>>
>>>> In the comment above, you said that the possible value for backup
>>>> corresponds with BOND_STATE_ACTIVE and BOND_STATE_BACKUP.
>>>>
>>>> So, should be:
>>>>
>>>> slave->backup =3D BOND_STATE_ACTIVE;
>>>>
>>>>> +}
>>>>> +
>>>>> +static inline void bond_set_backup_slave(struct slave *slave)
>>>>> +{
>>>>> +	slave->backup =3D 1;
>>>>
>>>> slave->backup =3D BOND_STATE_BACKUP;
>>>>
>>>
>>> Well, I think it's weird and misleading to assign some define to :1
>>> bitfield. Should be 0 or 1, nothing else.
>>
>> Agreed, but the comment appears missleading... May be you should fix=
 the comment, not the code.
>
> Hmm. I thought that the comment is accurate. BOND_STATE_ACTIVE
> corresponds with 0, BOND_STATE_BACKUP corresponds with 1. Anyway, let=
 me
> know how would you like to formulate this and I can repost (or do a
> little comment-changing followup)
>
> Thanks Nicolas

Hi Jiri,

I'm probably too perfectionist. Keep it the way it is.

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
