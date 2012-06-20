From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH] netxen: Error return off by one in 'netxen_nic_set_pauseparam()'.
Date: Wed, 20 Jun 2012 13:29:21 +0530
Message-ID: <CAOD=uF6Oe1KZqmtUpY57u9GJh9BqxoK0DP0n4yP_DrMUjfXbCQ@mail.gmail.com>
References: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120620074447.GS4400@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sony.chacko@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
	rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46185 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab2FTH7V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:59:21 -0400
In-Reply-To: <20120620074447.GS4400@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 20, 2012 at 1:14 PM, Dan Carpenter <dan.carpenter@oracle.co=
m> wrote:
> On Wed, Jun 20, 2012 at 12:57:39PM +0530, santosh nayak wrote:
>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> There are 'NETXEN_NIU_MAX_GBE_PORTS' =A0GBE ports. Port indexing sta=
rts
>> from zero.
>> Hence we should also return error for "port =3D=3D NETXEN_NIU_MAX_GB=
E_PORTS"
>>
>
> I don't know this code well enough to say if you are right or not,
> but what about for port =3D=3D NETXEN_NIU_MAX_XG_PORTS a few lines la=
ter
> in both functions?


I think "for port =3D=3D NETXEN_NIU_MAX_XG_PORTS"  error should be retu=
rned.


@Rajesh,

Can you please comment on it ?


regards
santosh

>
> regards,
> dan carpenter
>
