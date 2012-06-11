From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 2/3] bonding:check mode when modify primary_reselect
Date: Mon, 11 Jun 2012 14:28:14 -0700
Message-ID: <32303.1339450094@death.nxdomain>
References: <cover.1339404887.git.wpan@redhat.com> <5cef8fed5c7fbb9e7f18e61a2c9a47b45f87ca0d.1339404887.git.wpan@redhat.com> <4FD64A19.8000003@gmail.com> <31758.1339448166@death.nxdomain> <4FD65F78.2070001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59071 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab2FKV32 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 17:29:28 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 11 Jun 2012 15:29:27 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0B4E33E40059
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 21:29:11 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BLSV5G065196
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 15:28:55 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BLSFZo029837
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 15:28:16 -0600
In-reply-to: <4FD65F78.2070001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 11/06/2012 22:56, Jay Vosburgh a =C3=A9crit :
>> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com>  wrote:
[...]
>>> May I suggest we only issue a warning, store the new value for
>>> primary_reselect, and avoid calling bond_select_active_slave(bond),=
 if
>>> !USE_PRIMARY(bond->params.mode)?
>>>
>>> That way, we do not add one more constraint on the order one must w=
rite into sysfs.
>>
>> 	I'm not in favor of changing anything here.  There's already a
>> message that primary_reselect is being changed, I think that's
>> sufficient.  The other similar cases don't issue warnings, e.g., set=
ting
>> xmit_hash_policy doesn't complain if the mode is not one that utiliz=
es
>> the hash.
>
>Agreed. Calling bond_select_active_slave(bond) looks safe, even for mo=
de
>that does not use primary, so we don't need to change anything.
>
>Would you support other patch similar to 1/3 in this thread, that try =
to
>relax the order to write into sysfs for bonding?

	Yes.  As long as the setting takes effect when it should, I see
no problem with permitting options that are currently not applicable to
be changed at any time.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
