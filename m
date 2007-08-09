From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 GIT state
Date: Thu, 09 Aug 2007 04:10:34 -0700 (PDT)
Message-ID: <20070809.041034.93473045.davem@davemloft.net>
References: <20070809.022823.31781972.davem@davemloft.net>
	<Pine.LNX.4.64.0708091233050.24369@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760191AbXHILKf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 07:10:35 -0400
In-Reply-To: <Pine.LNX.4.64.0708091233050.24369@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 9 Aug 2007 12:50:51 +0300 (EEST)

> At least these are trivial to take (after rebase, some come nicely ev=
en=20
> from the before tree):
>=20
> 40564051bdb237231e625ba674fdedf6e8373027 [TCP]: Remove num_acked>0 ch=
ecks from cong.ctrl mods pkts_acked
> 4c035cd78a6b60710b0dda4f62339df070f761c8 [TCP]: Add tcp_dec_pcount_ap=
prox int variant
> ed2753b0b463df41c10121ce494d51428047fcbc [TCP]: Move code from tcp_ec=
n.h to tcp*.c and tcp.h & remove it
> c215314c6ea0261865d3df09f375016f3dcadeba [TCP]: Access to highest_sac=
k obsoletes forward_cnt_hint
> 9e5f432fb247af2f0062c3c57d7f45d511692f26 [TCP] FRTO: remove unnecessa=
ry fackets/sacked_out recounting
> 96001b306c60cb969d456ac70e376220db97e54a [TCP]: Move Reno SACKed_out =
counter functions earlier
> 318cf753170367504cfac07ac89e97befb1ca501 [TCP]: Extract DSACK detecti=
on code from tcp_sacktag_write_queue().
> a2539974b098065ebe02ad11a6411df4f56ba0ed [TCP]: Rexmit hint must be c=
leared instead of setting it
>   - Could be combined with the extrator as it's really a bug fix, onc=
e=20
>     rxmit cnt hint gets dropped, we can add this back as optimization=
 :-).
> 2fea67411f0c89642fa4abc0490b65c7852a1202 [TCP]: Extracted rexmit hint=
 clearing from the LOST marking code
> 1fba6548b2ecc2d513981898247472d1183329c5 [TCP]: Add highest_sack seqn=
o, points to globally highest SACK

Ok, in order to get this started I merged the above patches
into net-2.6.24

I'm exhausted and done for today. :-)

We can work on the other bits next.  Note that patches like the
"Create tcp_sacktag_foo" ones are just mechanical transformations
and thus if the conflicts are huge they can just be reimplemented
by hand.

> ...Taking IsReno/IsFack removal is probably going to be hardest one, =
as it=20
> will conflict a lot. ...Maybe some sed work in patches would reduce #=
 of=20
> conflicts instead of trying cherry-pick+rebase.

Yes, such patch hand editing techniques can help in these cases.
