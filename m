From: David Miller <davem@davemloft.net>
Subject: Re: mv643xx broken on pegasos
Date: Sun, 18 Jan 2009 21:59:11 -0800 (PST)
Message-ID: <20090118.215911.110220539.davem@davemloft.net>
References: <20090115012232.3852.qmail@kosh.dhis.org>
	<20090115203214.GB18393@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pacman@kosh.dhis.org, netdev@vger.kernel.org,
	buytenh@wantstofly.org
To: tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46739
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755960AbZASF7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:59:10 -0500
In-Reply-To: <20090115203214.GB18393@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Michlmayr <tbm@cyrius.com>
Date: Thu, 15 Jan 2009 21:32:14 +0100

> I just noticed that this bug has also been reported on the Pegasos
> forum: http://www.powerdeveloper.org/forums/viewtopic.php?p=11849
> The discussion doesn't contain a lot of information, except for this
> observation:
> 
> "I've been bisecting the problem today and the regression is indeed
> with one of Lennert's changes, but I would certainly not have bet on
> the innocent looking "mv643xx_eth: use longer DMA bursts" patch (git
> commit identifier cd4ccf76bfd2c36d351e68be7e6a597268f98a1a).
> 
> With this commit reverted, Gb ethernet is working again with kernel
> 2.6.27 on Pegasos."

Lennert, please work to resolve this problem.  If you don't
have time, I'm just going to revert that DMA burst change.

Thanks.
