From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 14/14] replace __inline__ by inline in include/linux (net
 related)
Date: Wed, 06 Feb 2008 11:39:27 +0100
Message-ID: <47A98E5F.7010207@fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com> <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> <20080206.213100.60768610.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:33388 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091AbYBFKpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 05:45:01 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m16Aiwoh212770
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:44:58 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16AiwK22089092
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 11:44:58 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16Aiv3O008215
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 11:44:58 +0100
In-Reply-To: <20080206.213100.60768610.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com> (at=
 Wed, 06 Feb 2008 10:14:19 +0100), Daniel Lezcano <dlezcano@fr.ibm.com>=
 says:
>=20
>> replace __inline__ by inline in include/linux (net related)
>>
>> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
>> ---
>>  include/linux/atm.h        |    4 ++--
>>  include/linux/atmsap.h     |    2 +-
>>  include/linux/hdlc.h       |   13 +++++++------
>>  include/linux/inetdevice.h |   14 ++++++--------
>>  include/linux/netlink.h    |    5 +++--
>>  include/linux/rtnetlink.h  |    2 +-
>>  6 files changed, 20 insertions(+), 20 deletions(-)
>=20
> Please do this change within the #ifdef __KERNEL__ .. #endif only.

Oups ! I didn't thought about userspace program when modifying these=20
headers. Thanks for catching this.

Hopefully, the patches can be applied separately. Is it possible to=20
discard this one ?
