From: Hermann Lauer <Hermann.Lauer@iwr.uni-heidelberg.de>
Subject: Re: sumgem problems with initializiation order at a 1000SX SERDES card [experimental patch]
Date: Mon, 8 Dec 2008 16:59:36 +0100
Message-ID: <20081208155936.GD16754@lemon.iwr.uni-heidelberg.de>
References: <20081125103029.GD12605@lemon.iwr.uni-heidelberg.de> <20081126.011809.241693537.davem@davemloft.net> <20081128000059.GA13712@lemon.iwr.uni-heidelberg.de> <20081204.173324.136036003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.uni-heidelberg.de ([129.206.210.211]:51923 "EHLO
	relay2.uni-heidelberg.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbYLHP7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 10:59:43 -0500
Content-Disposition: inline
In-Reply-To: <20081204.173324.136036003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 04, 2008 at 05:33:24PM -0800, David Miller wrote:

> And this new code is just a copy of the PHY init sequence on
> PCS, so we should split that out into a helper function instead
> of duplicating it.
> 
> Any time gem_reset() is invoked, the PCS is going to need to be
> reset like this, so let's do the advertisement reinit there.
> 
> Does this version of the fix work for you?

Yes, works the same. It has some delay before receiving packets works
after an ifconfig up or a reestablishing of the link, but thats
the same as with the experimental patch.
Probably the link state handling has to be improved, I'm not
shure my experimental patch was correct there.

But as the driver is working now with this patch on this hardware
and not without - please commit.

Thanks,
  Hermann

-- 
Netzwerkadministration/Zentrale Dienste, Interdiziplinaeres 
Zentrum fuer wissenschaftliches Rechnen der Universitaet Heidelberg
IWR; INF 368; 69120 Heidelberg; Tel: (06221)54-8236 Fax: -5224
Email: Hermann.Lauer@iwr.uni-heidelberg.de
