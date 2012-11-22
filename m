From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 8139cp: set ring address after enabling C+ mode
Date: Thu, 22 Nov 2012 22:39:50 +0100
Message-ID: <20121122213950.GA8873@electric-eye.fr.zoreil.com>
References: <50AD1972.5080403@pobox.com> <1353529639.26346.164.camel@shinybook.infradead.org> <50ADA05B.2000308@pobox.com> <20121121.233945.2225341904551631404.davem@davemloft.net> <50ADAFB7.7070704@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	jasowang@redhat.com, netdev@vger.kernel.org, slacky@cheapnet.it,
	rggjan@gmail.com, gilboad@gmail.com,
	Hayes Wang <hayeswang@realtek.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42063 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754867Ab2KVWEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 17:04:10 -0500
Content-Disposition: inline
In-Reply-To: <50ADAFB7.7070704@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff Garzik <jgarzik@pobox.com> :
> On 11/21/2012 11:39 PM, David Miller wrote:
> >From: Jeff Garzik <jgarzik@pobox.com>
> >Date: Wed, 21 Nov 2012 22:47:39 -0500
> >
> >>State A:  pre-b01af457, known working
> >>State B:  b01af457, known broken
> >
> >State A is also known buggy on the largest consumer of this driver,
> >the emulated hardware.
>
> >Please evaluate this realistically.
> 
> If the simulator fails to match the hardware, that is a simulator bug.

Yes.

> It is disappointing to work around someone else's software bug in
> the kernel.

Yes. :o/

I like David Woodhouse's C (attached patch) since 1) Realtek does
not seem to care about oldies 2) the emulation will not be fixed in a
decent timeframe 3) real 8139cp users care.

It would be nice if gilboad could give it a try (users Cced).

Btw David W., could consider adding artificial delays between the writes
and see if / when things start to fail (CpCmd write in cp_start_hw is an
unflushed posted write for instance).

-- 
Ueimor

--SUOF0GtieIMvvwua
Content-Type: application/x-gzip
Content-Disposition: attachment; filename="8139cp.patch.gz"
Content-Transfer-Encoding: base64

H4sICN2YrlAAAzgxMzljcC5wYXRjaACVVtty2zYQfTa/Yp9SXkRKjGTaGk/cuEqmzUOajKIH
TzsdDkSAIsYiyALQJU36Pf2PflkWIKkoDh1behClxe7Z28GRKM9zCMMV10CGVPItk2oomB4y
XTBpPkhG1prdDS/j8TSrowyWT/NzuKBsD3F2GV8+P4+i8zhJ6HQC8WiUTCZOGIZPzegEQfDk
rC9fQjg9vxhcQGAe43NAi9JE8wy2FaeQ1alkium02IGrtNxk2thqRCeagZ/VngNOF8LFmgt2
iESr/HHkJyc4oyVJCaUy1SC5WKX4/coJHDjL6l2cuLN6VtIBhobXWZ2V1DOHwdnQxzfwYVFg
eeASDWtGlIbFfo4gN4jngWCMgq5gySCrRM5XG4kGkmsmAUfSAGSVxA7rSlCMgyXXCtsAmxWI
ZMAEWa4ZjeAV0UQVjGnYxlEC//+XRONxg+HOAphVZUkEhTlbcYUZPJAsQxsTVGE2LFDbUo1P
WSHwN1U1OL6tzTee8Od88df+tU3eUxWuJIIbhKoEqKpkUBBJd3jSAHH9k8IETEC1VExuzRza
Eo4mBFwByfSGrNcfwa7ZTGtF5JKsWqBdgRjYXVlRE2ki2oEc6oms5xDfcWHj52nu/sa/5hjA
yGys9wwCmLTn6NEtH17YZR9x4RA8P4I9uD+D0T5vX16/d5PIPYRcX0OceO3jXvbgBSj+D6vy
I9JSpjIPpzF7n85v0/mb339NP7z54/VxssVJpd2fwQ9L66j+QUueaVyVqhm5w4CB3Sc98FKR
j4ZquCNVVJs1NRRrt9Xya8lypJ5v6KMN3W08Nid5rSsJ5hoypZiK4JeNxuUTbXOIAewMYINS
S7ZlQiPJIJdVCbQyUK/e3hj2SOQ32jbi+MZ1sD93dxZL3BLJCaKQGruRysTuKnkHOSpIRymr
AZeuFYD5/p2Az8jBdwLnAv+i7Fj1SqZWvaYXg6RHvJr2Uy7/flCD7kVwwR/TLDhrz1BTkRtb
nuEZPlvm4qcrJ+zXNbA9HTTVRcSrrpOL6SDGVozk9/byaGUdvcB9ezMbIbNGA1RFtOgqzeoN
uL6bpsYAvgculmlrtUUaZ88ztXwHMjkFZNKAYPsPi0H/2VcxCNHjQTEITxKDPu9Hbtw32U8S
g/AkMejzfrQ0S57uZ7UlT3NHFvtFgawqcIT7ETrD0Ifb21vzE4P/AzSUZIVUEpvSXDRizAiD
18/cMsdxvgA+AnRw2ggAAA==

--SUOF0GtieIMvvwua--
