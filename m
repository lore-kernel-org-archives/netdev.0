From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH] netxen: Error return off by one in 'netxen_nic_set_pauseparam()'.
Date: Wed, 20 Jun 2012 15:46:45 +0530
Message-ID: <CAOD=uF4qjMOQ3=dN_1ffo1T-0EZiQ7m0quFpfvzLyAoqodEmMA@mail.gmail.com>
References: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120620074447.GS4400@mwanda>
	<CAOD=uF6Oe1KZqmtUpY57u9GJh9BqxoK0DP0n4yP_DrMUjfXbCQ@mail.gmail.com>
	<13A253B3F9BEFE43B93C09CF75F63CAA81A886EF19@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47433 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753550Ab2FTKQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 06:16:46 -0400
In-Reply-To: <13A253B3F9BEFE43B93C09CF75F63CAA81A886EF19@MNEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 20, 2012 at 3:21 PM, Rajesh Borundia
<rajesh.borundia@qlogic.com> wrote:
> _______________________________________
> From: santosh prasad nayak [santoshprasadnayak@gmail.com]
> Sent: Wednesday, June 20, 2012 1:29 PM
> To: Dan Carpenter; Rajesh Borundia
> Cc: Sony Chacko; netdev; kernel-janitors@vger.kernel.org
> Subject: Re: [PATCH] netxen: Error return off by one in 'netxen_nic_s=
et_pauseparam()'.
>
> On Wed, Jun 20, 2012 at 1:14 PM, Dan Carpenter <dan.carpenter@oracle.=
com> wrote:
>> On Wed, Jun 20, 2012 at 12:57:39PM +0530, santosh nayak wrote:
>>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>>
>>> There are 'NETXEN_NIU_MAX_GBE_PORTS' =A0GBE ports. Port indexing st=
arts
>>> from zero.
>>> Hence we should also return error for "port =3D=3D NETXEN_NIU_MAX_G=
BE_PORTS"
>>>
>>
>> I don't know this code well enough to say if you are right or not,
>> but what about for port =3D=3D NETXEN_NIU_MAX_XG_PORTS a few lines l=
ater
>> in both functions?
>
>
> I think "for port =3D=3D NETXEN_NIU_MAX_XG_PORTS" =A0error should be =
returned.
>
>
> @Rajesh,
>
> Can you please comment on it ?
>
>
> regards
> santosh
>
>>
>> regards,
>> dan carpenter
>>
>
> Yes error should be returned for =A0both port =3D=3D NETXEN_NIU_MAX_X=
G_PORTS and
> port =3D=3D =A0NETXEN_NIU_MAX_GBE_PORTS.


Ok.

The current patch is for GBE port.
=46or XG port I will send another patch.

regards
santosh


>
>
> Rajesh
>
