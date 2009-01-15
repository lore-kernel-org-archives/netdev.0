From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: mv643xx broken on pegasos
Date: Thu, 15 Jan 2009 21:32:14 +0100
Message-ID: <20090115203214.GB18393@deprecation.cyrius.com>
References: <20090115012232.3852.qmail@kosh.dhis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org
To: pacman@kosh.dhis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:39406 "EHLO
	sorrow.cyrius.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934805AbZAOVDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 16:03:39 -0500
Content-Disposition: inline
In-Reply-To: <20090115012232.3852.qmail@kosh.dhis.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* pacman@kosh.dhis.org <pacman@kosh.dhis.org> [2009-01-14 20:22]:
> In 2.6.27 it was completely broken.

I just noticed that this bug has also been reported on the Pegasos
forum: http://www.powerdeveloper.org/forums/viewtopic.php?p=11849
The discussion doesn't contain a lot of information, except for this
observation:

"I've been bisecting the problem today and the regression is indeed
with one of Lennert's changes, but I would certainly not have bet on
the innocent looking "mv643xx_eth: use longer DMA bursts" patch (git
commit identifier cd4ccf76bfd2c36d351e68be7e6a597268f98a1a).

With this commit reverted, Gb ethernet is working again with kernel
2.6.27 on Pegasos."

-- 
Martin Michlmayr
http://www.cyrius.com/
