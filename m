From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH 4.1 11/56] mvneta: add forgotten initialization of autonegotiation bits
Date: Wed, 08 Jul 2015 21:36:38 +0200
Message-ID: <87k2uasapl.fsf@natisbad.org>
References: <20150708073237.780280770@linuxfoundation.org>
	<20150708073238.389781888@linuxfoundation.org>
	<559D5996.5080506@list.ru> <20150708173655.GA16101@kroah.com>
	<559D6DBE.4040900@list.ru>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, Stas Sergeev <stsp@users.sourceforge.net>,
	"David S. Miller" <davem@davemloft.net>,
	Sebastien Rannou <mxs@sbrk.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 36.223.133.77.rev.sfr.net ([77.133.223.36]:33382 "EHLO
	smtp.natisbad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbbGHTg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 15:36:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Stas Sergeev <stsp@list.ru> writes:

>>> Another problem was reported:
>>> https://lkml.org/lkml/2015/7/8/865
>>>
>>> So, while the above patch is correct and fixes what
>>> it should, the original patch has more problems to deal
>>> with. Maybe for stable it would be better to just revert
>>> the whole thing?
>> No, you will have to fix this in Linus's tree, right?  So I'll take the
>> patch that you get into there when that happens, I don't want to diverge
>> from what is in that tree.
> For Linus tree I am planning a new DT property to explicitly
> enable the inband status. I don't see any quick fix suitable for
> -stable, and new DT property will likely not be quickly accepted.
> If you don't want a revert, then the stable will likely have that
> regression for quite long, that's the warning.

I do not think the problem is to have a revert in -stable, it's more
having in in Linus tree *first* ;-)

> OTOH, the revert will remove the support for my board, so I
> won't be able to even test it, which is also not perfect.

ATM, the priority is more on fixing the regressions the initial patch
caused *for existing boards*. There were at least three boards which got
hit by first regression during 4.1-rc and a new one on the table now
that 4.1 is out. I understand your reluctance to revert the patch that
made mvneta work for your custom board but it's unfair for others that
are hit by the regressions it causes and have to spend time
bisecting/fixing it.

Anyway, if you come w/ a fix, I can commit to test it on the boards I
have.

Cheers,

a+
