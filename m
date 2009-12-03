From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 21:34:00 +0100
Message-ID: <4B1820B8.7050500@tvk.rwth-aachen.de>
References: <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
 <4B17A791.80808@tvk.rwth-aachen.de>
 <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi>
 <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:42839 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753490AbZLCUdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:33:55 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU3006W6FSPED60@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 21:34:01 +0100 (CET)
In-reply-to: <20091203202328.62d7551a@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rederic Leroy schrieb:
> Le Thu, 03 Dec 2009 15:10:11 +0100,
> Damian Lukowski <damian@tvk.rwth-aachen.de> a =C3=A9crit :
>>> I suppose adding || !tp->retrans_stamp into the false condition is
>>> fine as long as we don't then have a connection that can cause a
>>> connection to hang there forever for some reason (this needs to be
>>> understood well enough, not just test driven in stables :-)).
>>>
>>>> Unluckily, I still cannot reproduce the scp stalls here, so it
>>>> would be nice if Frederic printed retrans_stamp together with
>>>> icsk_ca_state and icsk_retransmits, please.
>>> It wouldn't hurt to know tp->packets_out and tp->retrans_out too,
>>> that might have some significant w.r.t what happens because of FRTO=
=2E
>> I made a patch for Frederic with Codebase
>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
>>
>> Thanks for testing.
>=20
> I made a new .11 trace with damian patch.
> The copy went to the end.=20

Ok, at least this "fix" seems to work at first glance, but the printk
is quite useless now. Could you run another test with the printk's but
without the retrans_stamp =3D=3D 0 check, please?

Thanks.
