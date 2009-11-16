From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Mon, 16 Nov 2009 22:08:53 +0100
Message-ID: <4B01BF65.1010203@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com> <4AFCFD86.6020504@gmail.com> <4AFD8421.6090003@gmail.com> <4B01BB33.7080702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44681 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754252AbZKPVIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 16:08:53 -0500
In-Reply-To: <4B01BB33.7080702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> William Allen Simpson wrote:
>> Here's my revised attempt (untested).  Any technical corrections?
>>
> Limited multiple (=3D) assignments to only 2 per line for readability
> (that in existing code have 4 per line and run well beyond 80 charact=
ers,
> triggering a warning in scripts/checkpatch.pl).
>=20
> Still no technical corrections.  Seeking Acks.
>=20

I am a bit uneasy on this patch, since apparently you have infrastructu=
re
to send DATA payload on SYN, but I thought it was an optional part of y=
our 'RFC'
and as such, being implemented later ?

I remember a previous remark from David that our skb queues would not c=
ontain
DATA on SYN packets...


