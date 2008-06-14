From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] iphase: doesn't call phy->start due to a bogus #ifndef
Date: Sat, 14 Jun 2008 17:24:05 -0400
Message-ID: <200806142124.m5ELO5m2004271@cmf.nrl.navy.mil>
References: <4848117C.5040801@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45613 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756735AbYFNVYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:24:18 -0400
In-reply-to: <4848117C.5040801@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <4848117C.5040801@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>	This causes the suni driver to oops if you try to use sonetdiag to
>get the statistics. Also add the corresponding phy->stop call to fix another
>oops if you try to remove the module.
>
>Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

looks good.  i will submit to davem with the next batch of atm patches.
