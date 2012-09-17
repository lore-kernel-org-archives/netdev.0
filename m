From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] Take care of xfrm policy when checking
 dst entries
Date: Mon, 17 Sep 2012 15:54:58 -0400 (EDT)
Message-ID: <20120917.155458.777649470378504320.davem@davemloft.net>
References: <5057688B.3030509@gmail.com>
	<20120917.142504.115219640757684297.davem@davemloft.net>
	<50577F74.9040200@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vyasevich@gmail.com, eric.dumazet@gmail.com, sds@tycho.nsa.gov,
	james.l.morris@oracle.com, eparis@parisplace.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754365Ab2IQTzE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 15:55:04 -0400
In-Reply-To: <50577F74.9040200@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 17 Sep 2012 21:52:20 +0200

> Le 17/09/2012 20:25, David Miller a =E9crit :
>> From: Vlad Yasevich <vyasevich@gmail.com>
>> Date: Mon, 17 Sep 2012 14:14:35 -0400
>>
>>> I think he expected you to take Eric's patch that removed those
>>> pieces.
>>
>> Eric's patch was a cleanup, so it went into 'net-next'.
>>
>> Nicolas's patch is a bonafide bug fix so needs to be
>> targetted at 'net'
> My fault, it was 'net-next'. I will rebase them against 'net'.
>=20
> Should I post the last one (4/4) separately, against net-next? Becaus=
e
> without the '3/4', the cleanup is a bit larger and will cause a
> conflict during the merge.

Actually Nicolas, hold off on this for a bit.

I'm reconsidering putting Eric's patch into 'net' and that would
allow me to use your v3 patches as-is.

Thanks.
