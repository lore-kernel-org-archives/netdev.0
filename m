From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 08:09:53 +0100
Message-ID: <4AE7EE41.7010408@gmail.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE78297.9000909@candelatech.com> <4AE7EC65.8000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51189 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756691AbZJ1HJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 03:09:52 -0400
In-Reply-To: <4AE7EC65.8000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Ben Greear a =E9crit :
>> Probably the right way is to give a cmd-line arg to set the buffer s=
ize
>> and also continue if the error is ENOBUFs (but print some error out
>> so users know they have issues).  I can make the attempt if that
>> sounds good to you.
>=20
> Real fix is to realloc buffer at receive time, no need for user setti=
ng.
>=20

Then, another problem is that some information can be dropped at kernel=
 level
when socket rcvbuf is full (ip monitor too slow to read its socket)

Thats hard to fix because you need to tweak /proc/sys/net/core/rmem_max


