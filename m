From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 09:00:08 +0100
Message-ID: <46038908.6050501@cosmosbay.com>
References: <1199CE22A40740D28833A585014BE559@XEON>
 <20070322.135834.74723088.davem@davemloft.net>
 <4602FD18.7060902@cosmosbay.com> <20070323.001126.40983698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:58290 "EHLO Smtp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422714AbXCWIAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 04:00:18 -0400
Received: from [192.168.30.10] ([86.66.237.19]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JFC009KOJK4XJ71@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 23 Mar 2007 09:00:05 +0100 (CET)
In-reply-to: <20070323.001126.40983698.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>

>> Welcome to the club :)
>=20
> Ok, how about we put something like the following into 2.6.21?

2.6.21 really ?

Just to be clear : I had an attack two years ago, I applied your patch,=
=20
rebooted the machine, and since then the attackers had to find another =
way to=20
hurt the machine. Eventually, when I update the kernel of this machine,=
 I=20
forget to appply jhash patch, and attackers dont know they can try agai=
n :)

I dont consider this new hash as bug fix at all, ie your patch might en=
ter=20
2.6.22 normal dev cycle.

Maybe a *fix*, independant of the hash function (so that no math expert=
 can=20
insult us), would be to have a *limit*, say... 1000 (something insane) =
on the=20
length of a hash chain ?

In my case, I saw lengths of about 3000 two years ago under attack, but=
=20
machine was still usable... maybe in half power mode.

