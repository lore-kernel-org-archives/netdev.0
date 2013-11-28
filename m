From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 Wake on Lan
Date: Thu, 28 Nov 2013 01:00:47 +0100
Message-ID: <20131128000047.GB5342@electric-eye.fr.zoreil.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
 <20131126232101.GA7508@electric-eye.fr.zoreil.com>
 <CAEv3EXFm5MrDeZLRyAZdVNoXWEGB7sU405+oM7K=o=eiAnUNPA@mail.gmail.com>
 <20131126235727.GA8466@electric-eye.fr.zoreil.com>
 <CAEv3EXHY6MzeUxmuJKtO51QMa8AirsVbPP5EgWTfNw941Q9i1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pablo Cholaky <mrwaltercool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36847 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758122Ab3K1AAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 19:00:50 -0500
Content-Disposition: inline
In-Reply-To: <CAEv3EXHY6MzeUxmuJKtO51QMa8AirsVbPP5EgWTfNw941Q9i1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Cholaky <mrwaltercool@gmail.com> :
> That's the logic:
> 
> - If I turn off my PC with WOL disabled using ethtool, WOL will be
> disabled (normal off, suspend to disk and suspend to RAM).
> 
> - If I turn on my PC,  WOL will always be turned on (including from
> suspend to disk and suspend to RAM)

The driver suspend / resume handlers should thus save and restore the
WoL state. It isn't rocket science but I won't hack it past midnight.

Thanks.

-- 
Ueimor
