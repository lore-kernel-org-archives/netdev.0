From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 4/8] bonding: wrap slave state work
Date: Tue, 8 Mar 2011 08:18:06 +0100
Message-ID: <20110308071805.GB2826@psychotron.redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
 <1299320969-7951-5-git-send-email-jpirko@redhat.com>
 <4D7254E9.6090605@gmail.com>
 <20110307095839.GC2832@psychotron.brq.redhat.com>
 <4D753820.2070608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33859 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752245Ab1CHHSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 02:18:15 -0500
Content-Disposition: inline
In-Reply-To: <4D753820.2070608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 07, 2011 at 08:55:12PM CET, nicolas.2p.debian@gmail.com wrote:
>Le 07/03/2011 10:58, Jiri Pirko a =E9crit :
>>>>
>>>>+static inline void bond_set_active_slave(struct slave *slave)
>>>>+{
>>>>+	slave->backup =3D 0;
>>>
>>>In the comment above, you said that the possible value for backup
>>>corresponds with BOND_STATE_ACTIVE and BOND_STATE_BACKUP.
>>>
>>>So, should be:
>>>
>>>slave->backup =3D BOND_STATE_ACTIVE;
>>>
>>>>+}
>>>>+
>>>>+static inline void bond_set_backup_slave(struct slave *slave)
>>>>+{
>>>>+	slave->backup =3D 1;
>>>
>>>slave->backup =3D BOND_STATE_BACKUP;
>>>
>>
>>Well, I think it's weird and misleading to assign some define to :1
>>bitfield. Should be 0 or 1, nothing else.
>
>Agreed, but the comment appears missleading... May be you should fix t=
he comment, not the code.

Hmm. I thought that the comment is accurate. BOND_STATE_ACTIVE
corresponds with 0, BOND_STATE_BACKUP corresponds with 1. Anyway, let m=
e
know how would you like to formulate this and I can repost (or do a
little comment-changing followup)

Thanks Nicolas

>
>	Nicolas.
>
